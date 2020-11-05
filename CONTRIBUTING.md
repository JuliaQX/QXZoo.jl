# Contributing to QuantEx

We welcome contributions and here we lay out some guidelines which should be followed to make the process more streamlined for all involved.

## Contribution process

Commits should not be pushed directly to the master branch but should instead be merged from branches following via pull/merge requests. To track 
tasks, features, bugs and enhancements should have a corresponding issue which explains the motivation and logic used in the committed code/documentation.
The steps in the full process from creating an issue to merging are:

1. Create issue with quick description of feature, bug, enhancement etc.. This will be assigned an issue number
2. Create a branch with a name that starts with the issue number and gives a concise description of the issue
3. Make the necessary changes to the branch. Commit messages should follow imperative style ("Fix bug" vs "Fixed bug"). Further guidelines for commit messages [here](https://gist.github.com/robertpainsi/b632364184e70900af4ab688decf6f53)
4. Ensure latest changes from `master` are on the feature branch (rebase, merge as necessary)
5. Ensure all relevant tests are passing and documentation is added/updated to reflect changes
6. If more than a single commit on the branch, squash (using `git rebase -i` is useful here) to a single commit with steps given in a changelog
7. Create a merge/pull request requesting to merge the changes into the master branch and assign appropriate reviewer
8. Once request is accepted the merge/pull request should be merged, the branch deleted and the issue status updated (closed if this is the case)
