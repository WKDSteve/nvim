Checke/review alle commits dieses chats die nicht reine docs waren auf Bugs, Security / Performance Optimierungen und fixe sie gleich.
Ich stelle das reasoning auf hoch oder mehr, damit du es gleich grün abhaken kannst.

Regeln dafür: `REVIEW-01` bis `REVIEW-04` (Commit-Liste, Review, Fix mit Test, Linter), Prüfen der Commits nach `CI-08` und
`CI-11` (Urteile lesen statt neu laufen lassen, `ci commit <sha>` im eigenen Worktree, keinen auslassen), Git nach `GIT-01`
bis `GIT-07`. Sie laden aus `~/.claude/rules/rules-vault-arbeit-*.md`; fehlen sie, statt dieser Vorlage `full_standalone.md`
nehmen.
