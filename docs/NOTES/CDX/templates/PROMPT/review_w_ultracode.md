Checke/review alle commits dieses chats die nicht reine docs waren auf Bugs, Security / Performance Optimierungen und fixe sie gleich.
Ich stelle das reasoning auf ultracode, damit du es gleich abhaken kannst.
Prüfe die Commits mit `scripts/test.sh ci commit <sha>` (eigener Worktree), nie im Arbeitsbaum, und lass keinen aus, weil die Suite rot ist.
Wurden die Commits schon direkt nach dem Erstellen geprüft (`ci commit <sha>` im Hintergrund), nur deren Urteil lesen statt sie neu laufen zu lassen; ungeprüfte einzeln nachholen.
