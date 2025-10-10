# git_bash

<p align="center">
  <img src="https://github.com/CultureLinux/git_bash/blob/main/docs/git_completion.png" alt="git_bash" style="width: 50%; max-width: 400px;"/>
</p>

Ce script Bash/Zsh fournit une **autocomplétion personnalisée** pour l'alias `g.c` qui execute `git add . && git commit -m `, afin de faciliter la saisie des messages de commit avec emojis et types prédéfinis (feat, fix, docs, etc.).

Il ajoute automatiquement un guillemet ouvrant `"` en début de message pour préparer la saisie du texte.

---

## Fonctionnalités

- Ajout de plusieurs alias pour faciliter git en ligne de commande
- Complétion des types de commit les plus courants avec emojis :
  - ✨ feat, 🐛 fix, 📝 docs, 💄 style, ♻️ refactor, ✅ test, 🔧 chore, ⚡ perf, etc.
- Tri alphabétique des suggestions pour retrouver rapidement le type souhaité.
- Compatible avec **Bash** et **Zsh**.
- Guillemet ouvrant ajouté automatiquement pour chaque suggestion.

---

## Installation

### Utilisateur

Exécute le oneliner suivant (il détecte Bash ou Zsh, ajoute la ligne de `source` dans le fichier de configuration et recharge la shell) :

```bash
cp .git_completion ~/.git_completion && \
if [ -n "$ZSH_VERSION" ]; then \
    SHELL_RC=~/.zshrc; \
elif [ -n "$BASH_VERSION" ]; then \
    SHELL_RC=~/.bashrc; \
else \
    echo "Shell non supporté"; exit 1; \
fi && \
grep -qxF "source ~/.git_completion" "$SHELL_RC" || \
echo "source ~/.git_completion" >> "$SHELL_RC" && \
source "$SHELL_RC"
```

### Système

Ajout l'autocomplétion pour tous les utilisateurs du système.

```bash
GC_FILE="/etc/bash_completion.d/git_completion"
sudo cp .git_completion "$GC_FILE"
sudo chmod 644 "$GC_FILE"

if [ -f /etc/bash.bashrc ]; then
    SHELL_RC="/etc/bash.bashrc"
elif [ -f /etc/bashrc ]; then
    SHELL_RC="/etc/bashrc"
else
    echo "Aucun bashrc système trouvé"; exit 1
fi

grep -qxF "source $GC_FILE" "$SHELL_RC" || echo "source $GC_FILE" >> "$SHELL_RC"
```
