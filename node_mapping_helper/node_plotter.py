import os
import cv2
import numpy as np
import json
import re
import tkinter as tk
from tkinter import filedialog

class ImageViewer:
    def __init__(self, image_path, points=None):
        if points is None:
            points = []
        self.image_path = image_path
        self.image = cv2.imread(self.image_path)
        self.window_name = 'Image Viewer'
        self.zoom = 1.0
        self.offset_x = 0
        self.offset_y = 0
        self.dragging = False
        self.last_x = 0
        self.last_y = 0
        self.points = points  #[x, y, label, connections]
        self.is_connecting = False
        self.selected_point = None
        self.connection_color = (255, 165, 0)
        self.point_color = (0, 0, 255)
        self.point_size = 3
        self.is_plotting = True

        self.guidelines = {'h': [], 'v': []} #store coords in image space
        self.is_guideline_mode = False
        self.guideline_color = (0, 255, 0)
        self.adding_guideline = False
        self.click_start_x = 0
        self.click_start_y = 0


    def screen_to_image_coords(self, x, y):
        x = (x - self.offset_x) / self.zoom
        y = (y - self.offset_y) / self.zoom
        return x, y

    def image_to_screen_coords(self, x, y):
        x = x * self.zoom + self.offset_x
        y= y * self.zoom + self.offset_y
        return x, y

    def find_closest_point(self, x, y, threshold=25):
        closest_dist = float('inf')
        closest_idx = -1
        for idx, (px, py, label, connections) in enumerate(self.points):
            screen_x, screen_y = self.image_to_screen_coords(px, py)
            dist = np.sqrt((x - screen_x) ** 2 + (y - screen_y) ** 2)
            if dist < threshold and dist < closest_dist:
                closest_dist = dist
                closest_idx = idx
        return closest_idx

    def find_closest_guideline(self, x, y, threshold=25):
        closest_dist = float('inf')
        g_type = None
        closest_idx = -1

        #check horizontal lines
        img_x, img_y = self.screen_to_image_coords(x, y)
        for idx, h_coord in enumerate(self.guidelines['h']):
            if abs(img_y - h_coord) < threshold and abs(img_y - h_coord) < closest_dist:
                closest_dist = abs(img_y - h_coord)
                g_type = 'h'
                closest_idx = idx

        #check verticals
        for idx, v_coord in enumerate(self.guidelines['v']):
            if abs(img_x - v_coord) < threshold and abs(img_x - v_coord) < closest_dist:
                closest_dist = abs(img_x - v_coord)
                g_type = 'v'
                closest_idx = idx

        return g_type, closest_idx

    def get_display_image(self):
        h, w = self.image.shape[:2]
        m = np.float32([[self.zoom, 0, self.offset_x], [0, self.zoom, self.offset_y]]) #get affine matrix to represent zoom scale and offset (dragging)
        display_image = cv2.warpAffine(self.image, m, (w, h)) #apply the matrix to the image
        self.draw_overlays(display_image)
        return display_image


    def add_label(self, x, y, image) -> str:
        #block mouse interrupts temporarily, use lambda to make throwaway function that does nothing since setMouseCallback requires a function to be passed in
        cv2.setMouseCallback(self.window_name, lambda _, __, ___, ____, _____: None, None)

        x = self.image_to_screen_coords(x, y)[0]
        y = self.image_to_screen_coords(x, y)[1]

        label = ""
        working_label_image = image.copy()

        cv2.circle(working_label_image, (int(x), int(y)), self.point_size, (0, 250, 0), -1)
        cv2.imshow(self.window_name, working_label_image)

        while True:
            key = cv2.waitKey(0) & 0xFF
            if 32 <= key <= 126:  #printable ASCII char/symbol
                label = label + chr(key)
            elif key == 8:  #backspace
                label = label[:-1]

                #recopy the image every backspace because opencv overwrites pixel values when marking the image so we erase characters by recopying the image before we added the current label and update the label without the last character
                working_label_image = image.copy()
                cv2.circle(working_label_image, (int(x), int(y)), self.point_size, (0, 250, 0), -1)

            #add character to label by overwriting the label on top of itself each time with the updated character (easiest method because opencv just overwrites pixel values)
            cv2.putText(working_label_image, label, (int(x), int(y)), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 250, 0), 1)
            cv2.imshow(self.window_name, working_label_image)

            if key == 13:  #enter
                #restore mouse interrupts
                cv2.setMouseCallback(self.window_name, self.mouse_callback, param=image)
                return label

    def mouse_callback(self, event, x, y, flags, param):
        #event is what triggers mouse_callback() flags are what happened during the event (ex shift was held down while left click)
        if event == cv2.EVENT_MOUSEWHEEL: #opencv repurposes flags as an int to indicate scroll direction when event == mousewheel
            if flags > 0: #scroll up
                self.zoom = self.zoom * 1.1
            else: #scroll down
                self.zoom = self.zoom / 1.1
        elif event == cv2.EVENT_LBUTTONDOWN:
            if self.is_connecting:
                idx = self.find_closest_point(x, y)
                if idx != -1:
                    if flags & cv2.EVENT_FLAG_SHIFTKEY: #if shift key was held down remove all connections to point clicked
                        px, py, label, *_ = self.points[idx] #*_ is a throwaway var because we do not care about existing connections when removing them. But we grab the point attributes to remove all connections to it later
                        self.points[idx] = [px, py, label, []] #remove all connections

                        #remove the selected point from other point connections
                        for i, (px, py, label, connections) in enumerate(self.points):
                            if idx in connections: #if the point to be removed is in other point's connections
                                new_connections = []
                                for connection in connections: #update the other point's connection list, excluding the point to be removed
                                    if connection != idx:
                                        new_connections.append(connection)
                                self.points[i] = [px, py, label, new_connections]

                    #since shift was not held down, assume we want to connect two points
                    elif self.selected_point is None: #if we have not already picked a point to start connecting from
                        self.selected_point = idx #the point we just picked is the first point to connect from
                        print("got the first point")
                    else: #the point we just picked is our second point, we can connect them now
                        if idx != self.selected_point:  #do not connect to self
                            #first point -> second point
                            px1, py1, label1, connections1 = self.points[self.selected_point]
                            if idx not in connections1: #idx is the second point here (the most recently picked one)
                                connections1.append(idx)
                                self.points[self.selected_point] = [px1, py1, label1, connections1]

                                #second point -> first point
                                px2, py2, label2, connections2 = self.points[idx]
                                if self.selected_point not in connections2:
                                    connections2.append(self.selected_point)
                                    self.points[idx] = [px2, py2, label2, connections2]
                                self.selected_point = None
                        else: #we most likely tried connecting to self so just set self as the selected point
                            self.selected_point = idx
                            print("tried picking self for second point")
                elif idx == -1 and self.selected_point: #if we had a point already but didn't find a closest point the second click, we likely wanted to connect but didn't click close enough to the second point so do nothing but save the last point
                    pass


            elif self.is_guideline_mode:
                if flags & cv2.EVENT_FLAG_SHIFTKEY: #remove guideline
                    g_type, idx = self.find_closest_guideline(x, y)
                    if idx != -1:
                        self.guidelines[g_type].pop(idx)
                else: #add guideline
                    self.click_start_x = x
                    self.click_start_y = y
                    self.adding_guideline = True
                    self.dragging = True

            elif self.is_plotting:
                if flags & cv2.EVENT_FLAG_SHIFTKEY: #remove point
                    idx = self.find_closest_point(x, y)
                    if idx != -1:
                        for i, (px, py, label, connections) in enumerate(self.points): #remove all connections to the point being removed
                            updated_connections = []
                            for connection in connections:
                                if connection != idx:
                                    if connection < idx:
                                        updated_connections.append(connection)
                                    else: #if the connection is to a point with an index value greater than the point to be removed was, decrease the connection value (index to the connected point) by 1 because removing a point shifts all points after it down an index
                                        updated_connections.append(connection - 1)
                            self.points[i] = [px, py, label, updated_connections]

                        self.points.pop(idx)
                else: #add point
                    orig_x, orig_y = self.screen_to_image_coords(x, y)

                    #check for nearest guideline and snap the point to it
                    g_type, idx = self.find_closest_guideline(x, y, threshold=25)
                    if g_type == 'h':
                        orig_y = self.guidelines['h'][idx]
                    elif g_type == 'v':
                        orig_x = self.guidelines['v'][idx]

                    label = self.add_label(orig_x, orig_y, param)

                    self.points.append([orig_x, orig_y, label, []])
            else: #in pan mode
                self.dragging = True
                self.last_x = x
                self.last_y = y

        elif event == cv2.EVENT_LBUTTONUP:
            if self.adding_guideline and self.dragging: #determine if drag was more horizontal or vertical for type of guideline
                img_x, img_y = self.screen_to_image_coords(x, y)
                dx = abs(x-self.click_start_x)
                dy = abs(y-self.click_start_y)

                if dx > dy:
                    self.guidelines['h'].append(img_y)
                else:
                    self.guidelines['v'].append(img_x)
                self.adding_guideline = False
            self.dragging = False

        elif event == cv2.EVENT_MOUSEMOVE:
            if self.dragging and not (self.is_plotting or self.is_guideline_mode): #we are panning
                dx = x - self.last_x
                dy = y - self.last_y
                self.offset_x = self.offset_x + dx
                self.offset_y = self.offset_y + dy
                self.last_x = x
                self.last_y = y

            self.last_x = x
            self.last_y = y



    def draw_overlays(self, display_image):

        #draw points, connections and guidelines within the viewable image
        for idx, point in enumerate(self.points):
            px, py, label, connections = point
            point_x, point_y = self.image_to_screen_coords(px, py)
            if 0 <= point_x < display_image.shape[1] and 0 <= point_y < display_image.shape[0]: #check if the point is supposed to be viewable on the current screen
                cv2.circle(display_image, (int(point_x), int(point_y)), self.point_size, self.point_color, -1)
                cv2.putText(display_image, label,(int(point_x), int(point_y - 10)), cv2.FONT_HERSHEY_SIMPLEX, 0.5, self.point_color, 1)

                for connected_point in connections:
                    connected_point_x, connected_point_y = self.image_to_screen_coords(self.points[connected_point][0], self.points[connected_point][1])
                    cv2.line(display_image, (int(point_x), int(point_y)),(int(connected_point_x), int(connected_point_y)), self.connection_color, 2)

        #draw guidelines
        h, w = display_image.shape[:2]
        dash_length = 10
        for h_coord in self.guidelines['h']:
            _, screen_y = self.image_to_screen_coords(0, h_coord)
            if 0 <= screen_y < h: #check if the guideline is viewable on the current display image
                for x in range(0, w, dash_length):
                    dash_end_x = min(x + dash_length, w)
                    cv2.line(display_image, (x, int(screen_y)),(dash_end_x, int(screen_y)), self.guideline_color, 1)

        for v_coord in self.guidelines['v']:
            screen_x, _ = self.image_to_screen_coords(v_coord, 0)
            if 0 <= screen_x < w:
                for y in range(0, h, dash_length):
                    dash_end_y = min(y + dash_length, h)
                    cv2.line(display_image, (int(screen_x), y),(int(screen_x), dash_end_y), self.guideline_color, 1)

    def export_points(self):
        floor_num = "0" #default value
        filename = self.image_path[:self.image_path.index(".")] #remove the file extension
        filename = filename + "_data.json"

        #use regex to find the last consecutive sequence of integers before the file extension
        match = re.search(r'(\d+)(?=\.\w+$)', self.image_path)
        if match:
            floor_num = match.group(1)  #first captured group

        #create nodes dictionary with proper format
        nodes = {}
        for idx, (x, y, label, connections) in enumerate(self.points):
            node_id = f"{floor_num}-{idx}"

            connections_str = ''
            for connection in connections:
                connected_point_id = f"{floor_num}-{connection}"
                if len(connections_str) > 0:
                    connections_str = connections_str + ","
                connections_str = connections_str + connected_point_id

            if label: #this is user assigned name to each point
                pass
            else:
                label = "EMPTY"

            nodes[node_id] = {
                "xPos": int(x),
                "yPos": int(y),
                "rooms": label,
                "connections": connections_str
            }

        #create final json
        data = {
            "floor": int(floor_num),
            "nodes": nodes
        }

        #export to file
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4)
        print(f"Points exported to {filename}")


    def display(self):
        cv2.namedWindow(self.window_name)

        while True:
            display_image = self.get_display_image()
            cv2.setMouseCallback(self.window_name, self.mouse_callback, param=display_image)

            if self.is_connecting:
                mode = "Connecting"
            elif self.is_guideline_mode:
                mode = "Guidelines"
            elif self.is_plotting:
                mode = "Point Plotting"
            else:
                mode = "Pan"

            instructions = [
                f"Mode: {mode}",
                "D: Pan Mode",
                "G: Guideline Mode",
                "P: Point Plotting Mode:",
                "C: Connection Mode:",
                "E: Export points",
                "ESC: Exit",
                "Pan Mode:",
                "   Left Click + Drag: Pan",
                "   Mouse Wheel: Zoom",
                "Guideline Mode:",
                "   Left Click: Add guide",
                "   Shift + Left Click: Remove guide",
                "Point Plotting Mode:",
                "   Left Click: Add point + label",
                "   Shift + Left Click: Remove point",
                "Connection Mode:",
                "   Left Click: Select/Connect points",
                "   Shift + Left Click: Clear connections to point"

            ]

            for i, text in enumerate(instructions):
                y = 30 + i * 20
                cv2.putText(display_image, text, (10, y),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)
                cv2.putText(display_image, text, (10, y),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 0), 1)

            cv2.imshow(self.window_name, display_image)

            key = cv2.waitKey(1) & 0xFF
            if key == 27:  #esc
                break
            elif key == ord('c'): #connecting points mode
                self.is_connecting = True
                self.is_plotting = False
                self.is_guideline_mode = False
                self.selected_point = None

            elif key == ord('e'): #export to json
                self.export_points()

            elif key == ord('p'): #point plotting mode
                self.is_connecting = False
                self.is_plotting = True
                self.is_guideline_mode = False
                self.selected_point = None

            elif key == ord('g'): #guideline mode
                self.is_connecting = False
                self.is_plotting = False
                self.is_guideline_mode = True
                self.selected_point = None

            elif key == ord('d'): #panning mode
                self.is_connecting = False
                self.is_plotting = False
                self.is_guideline_mode = False
                self.selected_point = None


        cv2.destroyAllWindows()




def get_points(json_path):
    points = []

    with open(json_path) as json_file:
        data = json.load(json_file)

        for nodeid, nodeinfo in data['nodes'].items():
            x_pos = float(nodeinfo['xPos'])
            y_pos = float(nodeinfo['yPos'])
            label = str(nodeinfo['rooms'])
            connections = str(nodeinfo['connections'])


            #use regex to get the index/count (number after the floor-), the connections
            connections = re.findall(r'(?<=\d-)\d+', connections) #this returns a list of strings
            connections = [int(connection) for connection in connections] #convert the list of strings to list of ints


            points.append([x_pos, y_pos, label, connections])


    return points



if __name__ == "__main__":
    root = tk.Tk()
    root.withdraw()
    file_path = filedialog.askopenfilename() #path to file, the last number/s will be automatically read as the floor number. If not numbers are present floor number defaults to 0

    existing_points = None
    directory = os.path.dirname(file_path)
    base_name = os.path.splitext(os.path.basename(file_path))[0]


    for file in os.listdir(directory):
        if base_name in file and file.endswith('.json'):
            existing_points = file
            break





    if existing_points:
        points = get_points(existing_points)
        viewer = ImageViewer(file_path, points)
        viewer.display()

    elif not existing_points:
        viewer = ImageViewer(file_path, points=None)
        viewer.display()

