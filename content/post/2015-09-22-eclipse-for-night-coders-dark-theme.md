+++
author = "Mari Donkers"
title = "Eclipse for night coders (dark theme)"
date = "2015-09-22"
description = "With my Eclipse running under KDE (Debian Linux) the dark themes in Eclipse suffer from side effects. Like the disappearance of the little menu in the title area of the window's tabs."
featured = false
tags = [
    "Computer",
    "Software",
    "KDE",
    "GUI",
    "IDE",
    "Eclipse",
]
categories = [
    "linux",
    "editors",
]
series = ["Linux"]
aliases = ["2015-09-22-eclipse-for-night-coders-dark-theme"]
thumbnail = "/images/eclipse-ide.svg"
+++

With my Eclipse running under KDE (Debian Linux) the dark themes in Eclipse suffer from side effects. Like the disappearance of the little menu in the title area of the window's tabs.
<!--more-->

# Alternative approach

Configure the Invert desktop effect under KDE system settings and use Ctrl-Meta-U to activate it for the Eclipse window (which uses the regular light theme). This gives a very nice dark theme like effect, which is perfect for coding when it's dark! You may want to adjust the `Selection background` color in the Eclipse settings, which can be found under

``` bash
Window->Preferences->General->Editors->Text Editors
```

# Screendump

![](/images/EclipseDarkThemeViaKDEInvertDesktopEffect.png)
