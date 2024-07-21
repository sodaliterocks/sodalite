![Bildschirmfoto von Sodalite](https://git.zio.sh/sodaliterocks/lfs/media/branch/main/graphics/screenshot/screenshot.png?u=7)

<h1 align="center">
    Sodalite
</h1>

<p align="center">
    <strong>Sodalite</strong> ist ein unveränderliches Desktop-Betriebssystem, das mit <a href="https://coreos.github.io/rpm-ostree/">rpm-ostree</a> und auf <a href="https://getfedora.org/">Fedora</a> aufgebaut ist &mdash; ähnlich wie <a href="https://silverblue.fedoraproject.org/">Fedora Silverblue</a> &mdash; es nutzt den <a href="https://elementary.io/docs/learning-the-basics">Pantheon-Desktop</a> und hält sich eng an das Ethos und den Workflow von <a href="https://elementary.io/open-source">elementary</a> hält. Ein Work-in-Progress, der als Produktions-Desktop durchaus brauchbar ist.
</p>

---

<h4 align="center">
    Hmm, es sind X Tage seit der letzten Übertragung vergangen; ist das immer noch aktiv?
</h4>

<p align="center">
    <strong>Ja.</strong>
</p>

<p align="center">
    Trotz einer sehr aktiven Commit-Historie ist Sodalite heutzutage ziemlich selbstversorgend &mdash; hauptsächlich dank der großartigen Leute von <a href="https://fyralabs.com">Fyra Labs</a> &mdash; und so kann das Repository Monate ohne jegliche Aktivität überstehen. Das bedeutet nicht, dass das Projekt aufgegeben wurde, zumal <a href="https://github.com/electricduck">der Entwickler</a> es als sein Hauptbetriebssystem verwendet. Unabhängig von der Aktivität des Repositorys werden zweimal pro Woche Aktualisierungen aus dem Repository erstellt: Protokolle sind unter <a href="https://github.com/sodaliterocks/sodalite/actions">Actions</a> verfügbar.
</p>

<p align="center">
    Psst! Wir sind auch auf <a href="https://t.me/sodalitechat">Telegram</a>. Es steht Ihnen zwar frei, <a href="https://github.com/sodaliterocks/sodalite/discussions">Discussions</a> zu verwenden, aber der Großteil der Diskussion über dieses Projekt wird auf Telegram stattfinden.
</p>

---

## 🎉 Installieren

> Da rpm-ostree eine sich ständig weiterentwickelnde Technologie ist und ISO-Installationen derzeit eine geringe Priorität haben, **sind derzeit keine ISOs verfügbar**. Ein bestehendes rpm-ostree-basiertes Betriebssystem wie [Fedora Silverblue](https://silverblue.fedoraproject.org/) ist erforderlich: Dieses Betriebssystem wird für die "Umstellung" auf Sodalite verwendet.

1. Installieren Sie eine rpm-ostree-basierte Version von Fedora, wie z.B. [Fedora Silverblue](https://silverblue.fedoraproject.org/), oder verwenden Sie eine bereits vorhandene Installation
2. Öffnen Sie ein Terminal und geben Sie diese Befehle ein:
   - `sudo ostree remote add --if-not-exists sodalite https://ostree.sodalite.rocks --no-gpg-verify`
   - `sudo ostree pull sodalite:sodalite/current/x86_64/desktop`*
   - `sudo rpm-ostree rebase sodalite:sodalite/current/x86_64/desktop`
3. Setzen Sie den Teekessel auf und machen Sie sich eine Tasse Tee. Es wird eine Weile dauern
4. Starten Sie neu, wenn Sie dazu aufgefordert werden. Verwenden Sie es, genießen Sie es, machen Sie etwas Cooles damit, (versuchen Sie) es kaputt zu machen &mdash; [senden Sie ein Ticket, wenn Sie es tun](https://github.com/sodaliterocks/sodalite/issues/new)!

_* Es sind mehrere Zweigstellen verfügbar; siehe [Zweigstellen](#zweigstellen)_

### Zweigstellen

Mehrere Zweige (oder Images) von Sodalite existieren nebeneinander und werden nebeneinander entwickelt; diese werden durch ihre Ref. unterschieden &mdash; wie jede andere rpm-ostree-Distribution &mdash; wobei `sodalite/<version>/<arch>/<edition>`:

#### Aktuell (Current)

|**`<version>`**|**`<arch>`**|**`<edition>`**|Freigabe|Basis|Status|
|-|-|-|-|-|-|
|`current`|`x86_64`|`desktop`|**6&#160;Kutai**&#160;|[Fedora&#160;39](https://docs.fedoraproject.org/en-US/releases/f39/)|[![Update: sodalite/current/x86_64/desktop](https://img.shields.io/github/actions/workflow/status/sodaliterocks/sodalite/update__sodalite.current.x86_64.desktop.yml?label=current%2Fx86_64%2Fdesktop)](https://github.com/sodaliterocks/sodalite/actions/workflows/update__sodalite.current.x86_64.desktop.yml)|

#### Lang (Long)

|**`<version>`**|**`<arch>`**|**`<edition>`**|Freigabe|Basis|Status|
|-|-|-|-|-|-|
|`long-6`|`x86_64`|`desktop`|**6&#160;Kutai**&#160;(Long)|[Fedora&#160;39](https://docs.fedoraproject.org/en-US/releases/f39/)|[![Update: sodalite/long-6/x86_64/desktop](https://img.shields.io/github/actions/workflow/status/sodaliterocks/sodalite/update__sodalite.long-6.x86_64.desktop.yml?label=long-6%2Fx86_64%2Fdesktop)](https://github.com/sodaliterocks/sodalite/actions/workflows/update__sodalite.long-6.x86_64.desktop.yml)|
|`long-5`|`x86_64`|`desktop`|**5.1&#160;Varri**&#160;(Long)|[Fedora&#160;38](https://docs.fedoraproject.org/en-US/releases/f38/)|[![Update: sodalite/long-5/x86_64/desktop](https://img.shields.io/github/actions/workflow/status/sodaliterocks/sodalite/update__sodalite.long-5.x86_64.desktop.yml?label=long-5%2Fx86_64%2Fdesktop)](https://github.com/sodaliterocks/sodalite/actions/workflows/update__sodalite.long-5.x86_64.desktop.yml)|

> Im Gegensatz zu **Aktuell** (`current`) aktualisieren diese Zweige nicht auf die aktuelle Hauptversion: **Updates werden am selben Tag wie die Fedora-Basisversion eingestellt**. Verwenden Sie diese Zweige nur, wenn es notwendig ist (z.B. problematische Treiber, die bestimmte Versionen erfordern, kritische Systeme usw.)

#### Weiter (Next)

|**`<version>`**|**`<arch>`**|**`<edition>`**|Release|Base|Status|
|-|-|-|-|-|-|
|`next`|`x86_64`|`desktop`|**6&#160;Kutai**&#160;(Next)&#160;|[Fedora&#160;39](https://docs.fedoraproject.org/en-US/releases/f39/)|[![Update: sodalite/next/x86_64/desktop](https://img.shields.io/github/actions/workflow/status/sodaliterocks/sodalite/update__sodalite.next.x86_64.desktop.yml?label=next%2Fx86_64%2Fdesktop)](https://github.com/sodaliterocks/sodalite/actions/workflows/update__sodalite.next.x86_64.desktop.yml)|
|`next`|`x86_64`|`desktop-gnome`|**7&#160;GNOME**&#160;(Next)&#160;|[Fedora&#160;40](https://docs.fedoraproject.org/en-US/releases/f40/)|[![Update: sodalite/next/x86_64/desktop-gnome](https://img.shields.io/github/actions/workflow/status/sodaliterocks/sodalite/update__sodalite.next.x86_64.desktop-gnome.yml?label=next%2Fx86_64%2Fdesktop-gnome)](https://github.com/sodaliterocks/sodalite/actions/workflows/update__sodalite.next.x86_64.desktop-gnome.yml)|

> Frühe Versionen der kommenden Versionen. Unstabil. Hier sind Drachen. Gebt alle Hoffnung auf. Sie wissen, wie es läuft.
>
> Dies kann manchmal die gleiche Version wie **Aktuell** (`current`) sein, aber seien Sie sich bewusst, dass Sie ohne Vorwarnung auf eine kommende Version verschoben werden, wenn Sie in diesem Zweig veröffentlicht werden.

### Versionierung

_(Todo)_

---

_(Todo: siehe [englische Version](../../README.md))_

---

<p align="center">
  <a href="../../README.md">🇬🇧</a>
  <a href="README.de.md">🇩🇪</a>
</p>

<p align="center">
    <i>Übersetzt von <a href="https://github.com/sodaliterocks/sodalite/blob/9f7115eaac6b2817396a213690cd628271caf602/README.md">9f7115e</a></i>
</p>
