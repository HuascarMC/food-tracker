![Audem logo]()

This is the base branch for the old Audem.

# Contribution Guide

The project is based on [Swift](https://developer.apple.com/swift/). (*try a [**Food tracker tutorial**](https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/) if you've never used*)

## Setting Up The Development Environment

1. Install xCode

  https://developer.apple.com/xcode/

2. create a fork of this repository and then

    `git clone repolink`

3. Set up git

      - `git remote add upstream original repo link`
      ```
        // make sure there are 2 remotes (origin that points to your fork and upstream for the original repo)
        git remote -v
      ```

    - **everytime you start working on a new feature, run: `git pull upstream develop` which ensures you are always working with the most updated version of the project.**

    - create a new branch `git checkout -b new-feature-name`

4. Open the project with xCode

5. Build and run the project

6. make changes

7. Build and run the project

8. If any issues found put on github.
