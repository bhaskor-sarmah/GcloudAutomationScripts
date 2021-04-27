[core]
        repositoryformatversion = 0
        filemode = false
        bare = false
        logallrefupdates = true
        symlinks = false
        ignorecase = true
[credential]
        helper = gcloud.sh
[remote "google"]
        url = https://source.developers.google.com/p/test-proj-19/r/test-repo-19
        fetch = +refs/heads/*:refs/remotes/google/*