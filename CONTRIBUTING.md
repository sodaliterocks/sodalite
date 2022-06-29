# Contributing to Sodalite

Awesome! Help is always appreciated, from bugfixes to potential new features. There's just a few things to know before you get going though, outlined below.

## Issues

(todo)

## Development

### Licensing

All code submitted into this repository will be [licensed as MIT](https://github.com/electricduck/sodalite/blob/main/LICENSE), which means:

* Grants commercial use, modification, distribution, and private use.
* Lacks liability or warranty.
* Original license (MIT) must stay intact.

### Branches

**This does not follow GitFlow.**

* `main` (default): **Development branch**
    * Contains the latest development version of `release/stable`.
    * Is merged (or cherry-picked) into `release/stable` when work is complete.
* `issue/*`: **Issue branches**
	* Contains work relating to an [issue](https://github.com/sodaliterocks/sodalite/issues).
	* Is merged into `main` when the issue is closed.
	* Named `issue/<id>-<short-name>`, where:
	    * `id`: Issue ID.
	    * `short-name`: Shortened kebab-case of issue title. For example:
	        * _Thing is broken_ becomes `thing-is-broken`;
	        * _Include this because it's better than that_ becomes `include-this`.
* `release/*`: **Production branches**
    * Contains the branches:
        * `release/stable`: **Ref for `sodalite/stable/<arch>/<variant>`**
        * `release/f<base>`: **Ref for `sodalite/f<base>/<arch>/<variant>`**
        * `release/next`: **Ref for `sodalite/next/<arch>/<variant>`**
    * Working code that is built on [the OSTree server](https://ostree.sodalite.rocks).
    * `main` in merged (or cherry-picked) into here, being careful not to adjust the `ref` or `releasever` properties in treefiles for other versions.

### Commit Messages

```
<emoji> [[#<issue>]] [<area>:] <message>

[<long-message>]
```

* `emoji`: See [Emojis](#commit-messages--emojis).
* `issue` _(optional)_: [Issue](https://github.com/electricduck/sodalite/issues) related to commit.
	* Surround it with square brackets (e.g. `[#1234]`).
* `area` _(optional)_: Specific area of the codebase.
	* Written in lowercase; proceeded with a colon (e.g. `thing:`).
	* This could be a filename (no extension), directory, or function name.
	* For more specificness, add a "parent" area in brackets (e.g. `child-thingy (parent-thingy):`).
* `message`: Brief message of changes.
	* Written in lowercase (unless a proper noun); written in present tense  (e.g. `modify` not `modified`); begin with a verb.
	* Some messages use a certain format:
		* **Branch merges** (with 🔀 emoji), use `from_branch → to_branch`.
		* **PR merges** (with 🔀 emoji), use `PR #123 (pr_branch)`.
		* **"Various changes"** (with 📦 emoji), use `various changes`.
			* Try and refrain from using this message!
* `long-message` _(optional)_: Extra details of changes and possible future work. Stick stuff in bullet points, type out a haiku, draw an ASCII cat, whatever is best: there are no rules here.

For inspiration, have a look through the history with `git log` (or `git log <file>` for a specific file). Ask if you need help!

<h3 id="commit-messages--emojis">Emojis</h3>

| Emoji | Description |
| ----- | ----------- |
| 🆕 (`:new:`) | Addition of user-facing feature |
| 🔧 (`:wrench:`) | Modifications or additions to code |
| ♻️ (`:recycle:`) | Refactoring, formatting, or typo-checking parts of code |
| 🐞 (`:beetle:`) | Fixing a bug |
| 🗑️ (`:wastebasket:`) | Removal of user-facing feature |
| ✨ (`:sparkles:`) | Preparing a version release |
| 🎨 (`:art:`) | Modifications or additions to assets, such as images |
| 📝 (`:memo:`) | Modifications or additions to documentation |
| 🧹 (`:broom:`) | Other non-user-facing chores, such as updating LFS modules |
| 🔀 (`:twisted_rightwards_arrows:`) | Merging branches or PRs |
| 🤔 (`:thinking:`) | Testing or empty commits |
| 📦 (`:package:`) | Various/unspecified changes |
| 🎉 (`:tada:`) | Initializing a repository |
| 🔥 (`:fire:`) | Archiving a repository |

### Coding Convention

Early days and I'm still working things out myself, but some things to keep in mind:

* The `./.editorconfig` file will keep a few things tidy, such as forcing an extra line onto the end of the file. Let it do its job!
	* If you're using Code, awesome, it supports EditorConfig out the box!
	* If you're using an editor which doesn't support EditorConfig out-the-box (such as Visual Studio Code, Atom, Sublime Text, Emacs, or Vim) [install an appropriate extension](https://editorconfig.org/#download).
* Keep to how the file is laid out but also stick to what you know. It can be cleaned up later!
* [Submit an issue](https://github.com/electricduck/sodalite/issues/new) if you feel something could be done in a better way.

### LFS Folder

At the root of the repo lies the mystical `./lfs` submodule which points to [ducky/sodalite-lfs on Zio Git](https://git.zio.sh/ducky/sodalite-lfs). This was done after Sodalite quickly utilized GitHub's puny LFS limits (just 1GiB bandwidth — in 2022!?). If you wish to change any of the files there please submit a ticket and I'll sort something out.
