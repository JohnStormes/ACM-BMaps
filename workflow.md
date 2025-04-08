# GitHub Workflow

## Branching Strategy

Each team member will work on their own feature or task using a separate branch. The branch format is `name-date` (e.g., `tymur-2024-10-21`). After committing and testing changes, team members will merge their changes into the `dev` branch. The `dev` branch will act as a staging area for code review and testing before it is merged into the `main` branch.

## Workflow Steps

1. **Clone the Repository (one time process)**  
   First, clone the repository to your local machine:
   ```bash
   git clone git@github.com:JohnStormes/Bing-room-finder-lame-ah-name-.git
   cd Bing-room-finder-lame-ah-name-/
   ```

2.  **Pull the Latest Changes in the Morning**
   Each day, before starting work, pull the latest changes from the `main` or `dev` branch to ensure you are working with the most up-to-date code:
   
   ```bash
   git checkout dev  # or main, depending on which one is the latest
   git pull origin dev
   ```
   Create a New Branch
   After pulling the latest changes, create your own branch using the name-date format:
   ```bash
   git checkout -b name-date
   ```
   ## Example
    ```git checkout -b tymur-2024-10-21```
   
   
3. **Make Changes and Commit**  
   Work on your changes locally. Once you’re ready, add the files and commit your changes:

   ```bash
   git add .(it is a bad practice to use git add . it is better to git add only the specific files you are working on i.e git add workflow.md)
   git commit -m "Descriptions of your changes"
   ```

4. **Push the Branch to GitHub**  
   Push your changes to the corresponding branch on GitHub:

   ```bash
   git push origin name-date
   # Example
   git push origin tymur-10-21
   ```

5. **Create a Pull Request (PR) to `dev`**  
   After testing your code locally, create a Pull Request (PR) to merge your branch into the `dev` branch:

   - Go to the repository
   - Click on "Pull requests"
   - Select your branch and create the PR, setting `dev` as the target branch.
   - Provide a detailed description of the changes in the PR.

6. **Review and Merge into `dev`**  
   - Another team member should review your PR.
   - After approval, merge your branch into the `dev` branch.

   To merge:

   - Click the "Merge pull request" button after approval.

7. **Test on `dev`**  
   After merging into `dev`, the code should be tested thoroughly. Once all features are integrated and working, a final PR can be made to merge the `dev` branch into `main`.

8. **Merge `dev` into `main`**  
   Once everything has been tested and approved on the `dev` branch, a designated person(probably John) will create a PR to merge the `dev` branch into `main`. This ensures that only stable and tested code goes into the `main` branch.

9. **Update the Local Repository**  
   After the merge is complete, everyone should update their local repository to stay up-to-date with the `dev` or `main` branch:

   ```bash
   git checkout main
   git pull origin main
   ```

   or, if you're continuing work on `dev`:

   ```bash
   git checkout dev
   git pull origin dev
   ```

## Testing

Each developer is responsible for testing their changes locally before creating a PR to the `dev` branch. After merging into `dev`, further testing will occur before promoting changes to `main`.

## Best Practices
- create a new branch every day (it's okay if you continue working on your previous branch to finish a feature).
- Ensure your commit messages are clear and descriptive.
- Test the integrated changes in the `dev` branch before merging into `main`.
- Resolve any merge conflicts locally before pushing.