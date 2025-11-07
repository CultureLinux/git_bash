# git_bash

<p align="center">
  <img src="https://github.com/CultureLinux/git_bash/blob/main/docs/git_completion.png" alt="git_bash" style="width: 50%; max-width: 200px;"/>
</p>

Ce script Bash/Zsh fournit des alias git ainsi qu'une **autocomplétion personnalisée** pour l'alias `g.c` et `gc` qui execute `git add . && git commit -m` ou `git commit -m`, afin de faciliter la saisie des messages de commit avec emojis et types prédéfinis (feat, fix, docs, etc.).

Il ajoute automatiquement un guillemet ouvrant `"` en début de message pour préparer la saisie du texte.

---

## Fonctionnalités

- Ajout de plusieurs alias pour faciliter git en ligne de commande
- Complétion des types de commit les plus courants avec emojis :
  - ✨ feat, 🐛 fix, 📝 docs, 💄 style, ♻️ refactor, ✅ test, 🔧 chore, ⚡ perf, etc.
- Tri alphabétique des suggestions pour retrouver rapidement le type souhaité.
- Compatible avec **Bash** et **Zsh**.
- Guillemet ouvrant ajouté automatiquement pour chaque suggestion.
- Mise à jour automatique pour les prochaines releases (uniquement en mode utilisateur).

## Alias

```
alias gs='git status'
alias g.='git add . -A'
alias g.c='git add . -A && git commit -m'
alias gba='git branch -a'
alias gc='git commit -m'
alias gcout='git checkout'
alias gdu='git diff @{upstream}'
alias gfd='git fetch --dry-run'
alias glog='git log --stat --pretty=short --graph'
alias glr='git remote -v'
alias glt='git tag'
```

---

## Installation

### Utilisateur

Exécute le oneliner suivant (il détecte Bash ou Zsh, ajoute la ligne de `source` dans le fichier de configuration et recharge la shell) :

```bash
wget -qO- https://raw.githubusercontent.com/CultureLinux/git_bash/main/install.sh | bash
```

### Système

Ajout l'autocomplétion pour tous les utilisateurs du système.

#### Bash

```bash
sudo dnf install bash-completion
sudo wget -O /etc/bash_completion.d/git_completion https://raw.githubusercontent.com/CultureLinux/git_bash/refs/heads/main/git_completion
```
