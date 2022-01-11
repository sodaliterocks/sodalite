# Contributing to Sodalite

Awesome! Help is always appreciated, from bugfixes to potential new features. There's just a few things to know before you get going though, outlined below.

## Licensing

All code submitted into this repository will be [licensed as MIT](https://github.com/electricduck/sodalite/blob/main/LICENSE), which means:

* Grants commercial use, modification, distribution, and private use.
* Lacks liability or warranty.
* Original license (MIT) must stay intact.

## Branches

* `main` (default): **Production branch**
	* Contains the latest production version of `stable` (as in the `stable` in `sodalite/stable/x86_64/base`) for all variants.
	* Is merged into `release/stable` as-soon-as-possible.
	* **Do not submit PRs to this branch!**
		* If you do they will be adjusted to point to `devel`, and rejected if they do not merge automatically.
* `devel`: **Development branch**
	* Contains the latest development version of `stable`.
	* Is merged into `main` when work is complete.
	* **This is likely where you'll spend most of your time.**
* `feature/*`: **Feature branches**
	* Contains upcoming large feature work.
	* Is merged into `devel` when work is complete.
* `release/*`: **Release branches**
	* Contains other versions besides `stable` (and `stable` itself).
	* `main` in cherry-picked into here, being careful not to adjust the `ref` properties in treefiles.
	* This is the working code that is built on [the OSTree server](https://ostree.zio.sh/repo).

## Commit Messages

```
<emoji> [[#<issue>]] [<area>:] <message>

[<long-message>]
```

* `emoji`: See [Emojis](#commit-messages--emojis).
* `issue` _(optional)_: [Issue](https://github.com/electricduck/sodalite/issues) related to commit.
	* Surround it with square brackets (e.g. `[#1234]`).
* `area` _(optional)_: Specific area of the codebase.
	* Written in lowercase; proceeded with a colon (e.g. `thing`:).
	* This could be a filename (no extension), directory, or function name.
	* For more specificness, add a "parent" area in brackets (e.g. `child-thingy (parent-thingy)`).
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
| 🐞 (`:beetle`) | Fixing a bug |
| 🗑️ (`:wastebasket:`) | Removal of user-facing feature |
| ✨ (`:sparkles:`) | Preparing a version release |
| 🎨 (`:art:`) | Modifications or additions to assets, such as images |
| 📝 (`:memo:`) | Modifications or additions to documentation |
| 🧹 (`:broom:`) | Other non-user-facing chores, such as renaming files |
| 🔀 (`:twisted_rightwards_arrows:`) | Merging branches or PRs |
| 🤔 (`:thinking:`) | Testing or empty commits |
| 📦 (`:package:`) | Various/unspecified changes |
| 🎉 (`:tada:`) | Initializing a repository |
| 🔥 (`:fire:`) | Archiving a repository |

## Coding Convention

Early days and I'm still working things out myself, but some things to keep in mind:

* The `./.editorconfig` file will keep a few things tidy, such as forcing an extra line onto the end of the file. Let it do its job!
	* If you're using Code, awesome, it supports EditorConfig out the box!
	* If you're using an editor which doesn't support EditorConfig out-the-box (such as Visual Studio Code, Atom, Sublime Text, Emacs, or Vim) [install an appropriate extension](https://editorconfig.org/#download).
* Keep to how the file is laid out but also stick to what you know. It can be cleaned up later!
* [Submit an issue](https://github.com/electricduck/sodalite/issues/new) if you feel something could be done in a better way.

## LFS Folder

At the root of the repo lies the mystical `./lfs` submodule which points to [ducky/sodalite-lfs on Zio Git](https://git.zio.sh/ducky/sodalite-lfs). This was done after Sodalite quickly utilized GitHub's puny LFS limits (just 1GiB bandwidth — in 2022!?). If you wish to change any of the files there please submit a ticket and I'll sort something out.
