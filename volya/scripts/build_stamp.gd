extends RefCounted
class_name BuildStamp

## Tento riadok prepisuje tools/deploy_android.ps1 pri kazdom builde.
## Zobrazuje sa vlavo hore v hre, aby bolo vidno, ci v telefone bezi
## naozaj ten build, ktory sme prave nasadili.
const STAMP := "dev (nebuildovane skriptom)"
