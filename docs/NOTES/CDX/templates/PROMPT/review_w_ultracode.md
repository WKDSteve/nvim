Checke/review alle commits dieses chats die nicht reine docs waren auf Bugs, Security / Performance Optimierungen und fixe sie gleich.
Ich stelle das reasoning auf ultracode, damit du es gleich abhaken kannst.
Prüfe die Commits nach `CI-11` (`scripts/test.sh ci commit <sha>` im eigenen Worktree, keinen auslassen, weil die Suite rot ist) und `CI-08` (die quick-Urteile der Commits und das volle Urteil des Endstands lesen statt neu laufen zu lassen; einen Commit voll nur, wenn er strittig ist oder ungeprüft blieb).
