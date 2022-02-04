# Sodalite

![Screenshot of Sodalite](https://git.zio.sh/ducky/sodalite-lfs/raw/branch/main/screenshots/screenshot.png?u=4)

## Quickstart

You better know what you're doing, sparky. To get going:

1) Install an OSTree version of Fedora, such as [Fedora Silverblue](https://silverblue.fedoraproject.org/), or any other rpm-ostree-based distro.
2) Open a terminal and issue these commands:
	* `sudo ostree remote add --if-not-exists sodalite https://ostree.sodalite.rocks --no-gpg-verify`
	* `sudo ostree pull sodalite:sodalite/stable/x86_64/base`
	* `sudo rpm-ostree rebase sodalite:sodalite/stable/x86_64/base`
3) Stick the kettle on and make yourself a cuppa. It'll take a while.
4) Reboot when prompted. Sit back in awe as the desktop loads up.
	* Updates will occur automatically if you update everything from Software (which runs in the background by default and sends desktops notifications).
	* As they are installed via Flatpak, various GNOME apps will still be lingering. Remove these with `sudo sodalite-hacks flatpak --remove-gnome-apps`.

Confused? Head down to [Getting](#getting).

## Background

Like most of us, I've been distro hopping since I was eating crayons, but as with anything in life there comes a point you need to settle down. I eventually found love for the fantastic [elementaryOS](https://elementary.io/): a beautifully crafted distro, packed with a few lovely apps and mated to the in-house Pantheon desktop. With very little customization, its not the experience for the most die-hard Linux fan, but I grew to love the workflow and UX patterns I found myself forced into.

Like every OS though, things begin to break down after years of abuse to its foundation. A tweak to something in /usr here, and a hack in /etc there: it piles up and I forget what I've done, leading to a grubby OS I'm going to need to eventually reinstall. _G r e a t_. Fedora had been something I'd been using on-and-off for the past year &mdash; installing Pantheon in place of GNOME, of course &mdash; leading me to eventually stumble across [Fedora Silverblue](https://silverblue.fedoraproject.org/) and [rpm-ostree](https://rpm-ostree.readthedocs.io/en/stable/). _Hm, a usable immutable OS, you say? Sounds glorious!_  And with that I give up a weekend to attempt to mate an old friend and a new idea, spending hours [searching through documentation](https://rpm-ostree.readthedocs.io/en/stable/manual/treefile/) and [peering at repositories](https://pagure.io/workstation-ostree-config), and soon stable platform with a charming desktop is born. Seems only right to share with the world.

So hello world, this is Sodalite: Pantheon and OSTree.

As a sidenote, a similar configuration exists in the [workstation-ostree-config repository on Pagure](https://pagure.io/workstation-ostree-config) (specifically in `./fedora-pantheon.yaml`) but that is a barebones vanilla install. Sodalite was actually partially inspired by this and builds upon it, providing a more finished product with the trademark elementary flourish.

## Status

This project is still very much early days and there is plenty of things that are broken, mostly due to missing upstream elementary/Pantheon packages on Fedora &mdash; Pantheon is _mostly_ distro-agnostic but still some way from being complete.

However, there's plenty of stuff that _does_ work rendering Sodalite entirely usable for day-to-day activites: it was even used to type up this README and build releases. Unless in this _Missing Apps_ list, every app included in elementaryOS comes with Sodalite and works 100% (probably)! That includes, **Music**, **Photos**, **Videos**, **Calendar**, **Files**, **Terminal**, **Code**, **Camera**, along with several other in-box utilities. AppCenter's Flatpak repository is also pre-installed giving you access to the ever-grown "curated" apps for elementaryOS.

### Missing Apps

* **AppCenter**<br />Although this builds on Fedora it refuses to work properly in rpm-ostree-based distros due to the nature of everything. Without proper support for OSTree, and a lack of PackageKit in the host, errors are thrown and nothing really loads in. _GNOME Software_ instead serves as a replacement, along with the AppCenter Flatpak repository being pre-installed.
* **Web**<br />As Fedora uses Firefox as the default browser, Web (Epiphany) is not installed by default. You can rectify this by running `sodalite-hacks flatpak --install-epiphany`.

### Other Issues

* Various System Settings (Switchboard) items are not included or do not work right.
* Various theming issues, due to be fixed in the upstream:
	* Some apps appear odd, such as Firefox which entirely lacks rounded corners.
* Many Flatpak apps will be duplicated in the Dock: see [issue #64 on elementary/dock](https://github.com/elementary/dock/issues/64). Although this is one of many issues across elementary, this was worth bringing up. Nothing broke on your end!
* ~~Not enough people are using this masterpiece.~~

<h2 id="getting">Getting</h2>

Ready? It's easy. Ish. Hold out your hand and I'll guide you.

An OSTree repository has already been setup for Sodalite, so you don't even need to build it yourself (hurrah!)

1) If you haven't already, install an OSTree version of Fedora, such as [Fedora Silverblue](https://silverblue.fedoraproject.org/download), or any other rpm-ostree-based distro.
	* If you've never used Fedora Silverblue before, **[read the docs](https://docs.fedoraproject.org/en-US/fedora-silverblue/)**. Get to know the OS, (try to) break it, reinstall it, repeat.
	* Custom partitioning is unsupported but does work from experience. The installer is flaky however, and will often stumble on basic problems and giving you very little guidance on what went wrong. For example, `fedora` still being present in the EFI partition if leftover from a previous install &mdash; just delete the directory!
	* If you're feeling adventurous, install [Fedora IoT](https://getfedora.org/iot/) instead &mdash; it's OSTree too, plus the ISO is over half the size.
2) Open a terminal and issue the following commands with superuser privileges (as `root`, or with `sudo`):
	1) `ostree remote add --if-not-exists sodalite https://ostree.sodalite.rocks --no-gpg-verify`<br />This adds the remote OSTree repository.
        - `--no-gpg-verify` is important as there is no GPG verification.
        - Previous versions of this document use the remote `https://ostree.zio.sh/repo` (named `zio`). This endpoint is still up (in fact, `https://ostree.sodalite.rocks` just redirects to it) and can be used instead. If you're still using it there is no need to change it: everything will still work.
	2) `ostree pull sodalite sodalite/stable/x86_64/base`<br />This pulls the OSTree image for Sodalite, and is split up into four parts (similar to that of Fedora Silverblue). These parts can be substituted for other values:
		1) `sodalite`: The **name** of the image.
		2) `stable`: The **version** of the image. Possible values:
            * `stable`: Rolling-release version based on the current stable version of Fedora Linux (as of currently, Fedora Linux 35).
        3) `x86_64`: The **architecture** of the image. Possible values:
            * `x86_64`: For 64-bit CPUs (`x86_64`, `amd64`, or — please stop saying this — `x64`).
            * <s>`x86`: [What year is it!?](https://c.tenor.com/9OcQhlCBNG0AAAAd/what-year-is-it-jumanji.gif)</s>
        4) `base`: The **variant** of the image. Possible values:
            * `base`: Everything you'll need to get going (hopefully). Other variants are built on-top of this.
            * `elementary-nightly`: Includes nightly versions of elementary/Pantheon packages. See [elementary-nightly](https://decathorpe.com/fedora-elementary-nightly-status.html) for more details.
	3) `rpm-ostree rebase sodalite:sodalite/stable/x86_64/base`<br />This rebases the OS onto Sodalite's image. Remember to substitute any values from before into this one!
3) Reboot when prompted with `systemctl reboot`.
4) Once logged in, defaults should apply and everything should be as it should.

### Post-install

#### Updating

Performing a system update can be done by either:

- Running `rpm-ostree upgrade` at a terminal.
- Opening **Software**, navigating to **Updates** and pressing **Update All**.
  - As Software runs in the background and periodically checks for updates, you may also receive a notification of a new update; clicking on this opens the appropriate page.
  - An update for the OS may take a while to appear in Software (which will appear as "Operating System Updates"), so the above method is preferred.

Reboot after either method has finished. You can verify the version installed by opening **System Settings** and navigating to **System ➔ Operating System**: the version proceeds the word "Sodalite".

If something breaks, you can rollback by calling `rpm-ostree rollback` at a terminal. Remember to also [create a new issue](https://github.com/sodaliterocks/sodalite/issues/new) if appropriate!

#### GNOME apps

Unless removed beforehand, you'll have a tonne of GNOME apps still installed from Flatpak. As Flatpak apps are part of the "user" part of the OS they cannot be programatically removed during the rebase. These apps work fine in Pantheon, and will use the default Adwaita theme, but look extremely out-of-place.

Run `sodalite-hacks flatpak --remove-gnome-apps` to remove them all.

#### Web / Epiphany

As Firefox is Fedora's default browser, we have chose to respect that decision and leave it be. However, Pantheon's preferred browser of choice is a patched version of [Epiphany](https://wiki.gnome.org/Apps/Web) distributed via the AppCenter Flatpak repository.

Run `sodalite-hacks flatpak --install-epiphany` to install.

### Removal

(todo &mdash; OSTree has several ways and its dependant on your install!)

## Building

(todo)

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Acknowledgements

* [Fabio Valentini ("decathorpe")](https://decathorpe.com/), for providing the extra packages for elementary on Fedora via the [elementary-staging Copr repository](https://copr.fedorainfracloud.org/coprs/decathorpe/elementary-staging/).
* [Jorge O. Castro](https://github.com/castrojo), for including Sodalite in [awesome-immutable](https://github.com/castrojo/awesome-immutable).
* [Timothée Ravier](https://tim.siosm.fr), for their extensive guidance to the community concerning Fedora Silverblue.
* ["Topfi"](https://github.com/ACertainTopfi), for their various contributions (and joining [@sodaliterocks](https://github.com/sodaliterocks)!).
* The [elementary team](https://elementary.io/team), for building lovely stuff.
* The contributors to [workstation-ostree-config](https://pagure.io/workstation-ostree-config), for a solid ground to work from.
* The amazing photographers/artists of the included wallpapers:
	* [Adrien Olichon](https://unsplash.com/@adrienolichon)
	* [Austin Neill](https://unsplash.com/@arstyy)
	* [Cody Fitzgerald](https://unsplash.com/@cfitz)
	* [Dustin Humes](https://unsplash.com/@dustinhumes_photography)
	* [Jack B.](https://unsplash.com/@nervum)
	* [Karsten Würth](https://unsplash.com/@karsten_wuerth)
	* [Max Okhrimenko](https://unsplash.com/@maxokhrimenko)
	* [Nathan Dumlao](https://unsplash.com/@nate_dumlao)
	* [Ryan Stone](https://unsplash.com/@rstone_design)
	* [Smaran Alva](https://unsplash.com/@smal)
	* [Willian Daigneault](https://unsplash.com/@williamdaigneault)
	* [Zara Walker](https://unsplash.com/@mojoblogs)
* The [Sodalite mineral](https://en.wikipedia.org/wiki/Sodalite), for the name. [It's a mineral, not a rock, Jesus](https://www.youtube.com/watch?v=r1yYJBzf1VQ)!
* The Omicron variant of COVID-19, for giving [Ducky](https://github.com/electriduck) the initial free time to make this thing. That's not even a joke, that's literally what happened.

## License

See **[LICENSE](LICENSE)**. It's MIT, alright, like every awesome pile of code.
