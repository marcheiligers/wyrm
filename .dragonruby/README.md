These are the changes made:

## Loading

Removed the check for everything except Chrome with the window.self !== window.top check and the horrible white text to load the game.

```js
// only chrome seems to work with iFrames (Itch.io)
if (isSafari() || isMobileSafari() || isAndroid() || isNestedIFrame() || isFirefox()) {
  if (window.self !== window.top) {
    document.body.innerHTML = "<a style='margin-left: auto; margin-right: auto; margin-top: 50px; font-family: monospace; color: white; visited: white; font-size: 20px; text-align: center; display: block; width: 300px; height: 100%;' target='_top' href='" + window.self.location.href + "'>Click Here to Load Game</a>";
  } else {
  loadLoadMainModule();
  // }
} else {
  loadLoadMainModule();
}
// end of dragonruby-html5-loader.js ...
```

Became

```js
  loadLoadMainModule();
```

## Click to play

Updated the `startClickToPlay` function to read:

```js
  startClickToPlay: function () {
    var div = document.createElement("div");
    div.id = "clicktoplaydiv";
    div.style.width = "50%";
    div.style.height = "50%";
    div.style.backgroundColor = "rgb(40, 44, 52)";
    div.style.position = "absolute";
    div.style.top = "50%";
    div.style.left = "50%";
    div.style.transform = "translate(-50%, -50%)";
    div.style.backgroundImage = "url('clicktoplaydiv.png')";
    div.style.backgroundSize = "contain";
    div.style.backgroundPosition = "center";
    div.style.backgroundRepeat = "no-repeat";

    document.body.appendChild(div);
    div.addEventListener("click", Module.clickToPlayListener);
    document.addEventListener("keydown", Module.enterPressedCallback);

    window.gtk.play = Module.clickToPlayListener;
  },
```
