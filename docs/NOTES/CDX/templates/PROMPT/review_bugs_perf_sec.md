Checke/review alle commits dieses chats die nicht reine docs waren auf Bugs, Security / Performance Optimierungen und fixe sie gleich.
Ich stelle das reasoning auf hoch oder mehr, damit du es gleich grün abhaken kannst.
Prüfe die Commits mit `scripts/test.sh ci commit <sha>` (eigener Worktree), nie im Arbeitsbaum, und lass keinen aus, weil die Suite rot ist.
Die Commits haben ihr quick-Urteil schon nach dem Erstellen bekommen (`ci commit <sha> --quick`) und der Endstand sein volles (`CI-02`): diese Urteile lesen statt neu laufen zu lassen; einen einzelnen Commit voll (`scripts/test.sh ci commit <sha> --wsl -- --cached`) nur, wenn er strittig ist oder ungeprüft blieb. Regeln: `$RULES_VAULT/rulesets/arbeit/regeln/CI_TAKT.md`.
