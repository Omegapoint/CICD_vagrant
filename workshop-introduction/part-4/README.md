# Introduction to CI/CD - Part 4

## Goal

The goal of the final part of the workshop is to have to different pipelines: one that will run continuous integration 
on all branches except the master branch. The master branch will be treated differently and will continuous deploy all 
to production when changes are pushed to the master branch.

### 1. Separate the pipelines

If the general SCM checkout is being used, the branch name is provided as a variable that can be used
 to branch the pipeline code. (See the provided `Jenkinsfile` in this folder if you get stuck)
 

