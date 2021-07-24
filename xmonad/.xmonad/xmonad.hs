import qualified Codec.Binary.UTF8.String as UTF8
import Control.Monad (liftM2)
import qualified DBus as D
import qualified DBus.Client as D
import qualified Data.ByteString as B
--
--
--
import Data.Char (isSpace, toUpper)
import qualified Data.Map as M
import Data.Maybe (fromJust, isJust)
import Data.Monoid
import Data.Tree
import Graphics.X11.ExtraTypes.XF86
import System.Directory
import System.Exit
import System.IO
--
-- Base
--
import XMonad
--
-- Action
--
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotAllDown, rotSlavesDown)
import qualified XMonad.Actions.Search as S
import XMonad.Actions.SpawnOn
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (killAll, sinkAll)
import XMonad.Config.Azerty
import XMonad.Config.Desktop
--
-- Hooks
--
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.WorkspaceHistory
--
-- Layouts
--
import XMonad.Layout.Accordion
import XMonad.Layout.CenteredMaster (centerMaster)
import XMonad.Layout.Cross (simpleCross)
import XMonad.Layout.Fullscreen (fullscreenFull)
import XMonad.Layout.Gaps
import XMonad.Layout.GridVariants (Grid (Grid))
import XMonad.Layout.IndependentScreens
--
-- Layouts modifiers
--
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (decreaseLimit, increaseLimit, limitWindows)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (EOT (EOT), mkToggle, single, (??))
import qualified XMonad.Layout.MultiToggle as MT (Toggle (..))
import XMonad.Layout.MultiToggle.Instances (StdTransformers (MIRROR, NBFULL, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing
import XMonad.Layout.Spiral
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import qualified XMonad.Layout.ToggleLayouts as T (ToggleLayout (Toggle), toggleLayouts)
import XMonad.Layout.WindowArranger (WindowArrangerMsg (..), windowArrange)
import XMonad.Layout.WindowNavigation
import qualified XMonad.StackSet as W
--
-- Utilities
--
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeys, additionalKeysP, additionalMouseBindings)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

{-
  Variables
    mod4Mask == super key
    mod1Mask == alt key
    controlMask == ctrl key
    shiftMask == shift key
-}
myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "alacritty" -- Sets default terminal

myBrowser :: String
myBrowser = "vivaldi-stable" -- Sets qutebrowser as browser

myFileManager :: String
myFileManager = "thunar"

myEmacs :: String
myEmacs = "emacsclient -c -a 'emacs' " -- Makes emacs keybindings easier to type

myEditor :: String
myEditor = "emacsclient -c -a 'emacs' " -- Sets emacs as editor
-- myEditor = myTerminal ++ " -e vim "    -- Sets vim as editor

myBorderWidth :: Dimension
myBorderWidth = 2 -- Sets border width for windows

myNormColor :: String
myNormColor = "#4c566a" -- Border color of normal windows

myFocusColor :: String
myFocusColor = "#5e81ac" -- Border color of focused windows

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

-- encodeCChar = map fromIntegral . B.unpack
-- myWorkspaces = ["\61612", "\61899", "\61947", "\61635", "\61502", "\61501", "\61705", "\61564", "\62150", "\61872"]
-- myWorkspaces = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
--myWorkspaces    = ["I","II","III","IV","V","VI","VII","VIII","IX","X"]
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]

myWorkspaceIndices = M.fromList $ zip myWorkspaces [1 ..]

-- Clickable workspaces
clickable ws = "<action=xdotool key super+" ++ show i ++ ">" ++ ws ++ "</action>"
  where
    i = fromJust $ M.lookup ws myWorkspaceIndices

myBaseConfig = desktopConfig

{-
  StartupHook
-}
myStartupHook :: X ()
myStartupHook = do
  spawnOnce "$HOME/.xmonad/scripts/autostart.sh"
  setWMName "LG3D"

-- TODO
-- myStartupHook = do
--     spawnOnce "lxsession &"
--     spawnOnce "picom &"

--     spawnOnce "volumeicon &"
--     spawnOnce "conky -c $HOME/.config/conky/xmonad.conkyrc"
--     spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x282c34  --height 22 &"
--     spawnOnce "/usr/bin/emacs --daemon &" -- emacs daemon for the emacsclient
--     -- spawnOnce "kak -d -s mysession &"  -- kakoune daemon for better performance
--     -- spawnOnce "urxvtd -q -o -f &"      -- urxvt daemon for better performance

--     spawnOnce "xargs xwallpaper --stretch < ~/.xwallpaper"  -- set last saved with xwallpaper
--     -- spawnOnce "/bin/ls ~/wallpapers | shuf -n 1 | xargs xwallpaper --stretch"  -- set random xwallpaper
--     -- spawnOnce "~/.fehbg &"  -- set last saved feh wallpaper
--     -- spawnOnce "feh --randomize --bg-fill ~/wallpapers/*"  -- feh set random wallpaper
--     -- spawnOnce "nitrogen --restore &"   -- if you prefer nitrogen to feh
--     setWMName "LG3D"

{-
  END StartHook
-}

-- window manipulations
myManageHook =
  composeAll . concat $
    -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
    -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
    [ [isDialog --> doCenterFloat],
      [isFullscreen --> doFullFloat],
      [className =? c --> doCenterFloat | c <- myCFloats],
      [title =? t --> doFloat | t <- myTFloats],
      [resource =? r --> doFloat | r <- myRFloats],
      [resource =? i --> doIgnore | i <- myIgnores],
      [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo (head myWorkspaces) | x <- my1Shifts],
      [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo (myWorkspaces !! 1) | x <- my2Shifts],
      [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo (myWorkspaces !! 2) | x <- my3Shifts],
      [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo (myWorkspaces !! 3) | x <- my4Shifts],
      [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo (myWorkspaces !! 4) | x <- my5Shifts],
      [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo (myWorkspaces !! 5) | x <- my6Shifts],
      [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo (myWorkspaces !! 6) | x <- my7Shifts],
      [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo (myWorkspaces !! 7) | x <- my8Shifts],
      [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo (myWorkspaces !! 8) | x <- my9Shifts],
      [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo (myWorkspaces !! 9) | x <- my10Shifts]
    ]
  where
    -- scratchpads todo
    -- <+> namedScratchpadManageHook myScratchPads

    doShiftAndGo = doF . liftM2 (.) W.greedyView W.shift
    myCFloats =
      [ "Arandr",
        "Arcolinux-calamares-tool.py",
        "Arcolinux-tweak-tool.py",
        "Arcolinux-welcome-app.py",
        "Galculator",
        "feh",
        "mpv",
        "Xfce4-terminal",
        "confirm",
        "file_progress",
        "dialog",
        "download",
        "error",
        "Gimp",
        "notification",
        "pinentry-gtk-2",
        "splash",
        "toolbar"
      ]
    myTFloats = ["Downloads", "Save As...", "Oracle VM VirtualBox Manager"]
    myRFloats = []
    myIgnores = ["desktop_window"]
    my1Shifts = ["Chromium", "Vivaldi-stable", "Firefox"]
    my2Shifts = []
    my3Shifts = ["Inkscape"]
    my4Shifts = ["Telegram", "WhatsApp", "Signal", "discord"]
    my5Shifts = ["Gimp", "feh"]
    my6Shifts = ["vlc", "mpv"]
    my7Shifts = ["Virtualbox"]
    my8Shifts = ["Thunar"]
    my9Shifts = []
    my10Shifts = []

{-
  Layouts ARCO
-}
myLayout1 = spacingRaw True (Border 0 5 5 5) True (Border 5 5 5 5) True $ avoidStruts $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) $ tiled ||| Mirror tiled ||| spiral (6 / 7) ||| ThreeColMid 1 (3 / 100) (1 / 2) ||| Full
  where
    tiled = Tall nmaster delta tiled_ratio
    nmaster = 1
    delta = 3 / 100
    tiled_ratio = 1 / 2

{-
  Layouts DT
-}
--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
{-
    E.g:
    ResizableTall tiled
      tiled = Tall nmaster delta tiled_ratio []
      nmaster = 1
      delta = 3 / 100
      tiled_ratio = 1 / 2
-}

floats =
  renamed [Replace "floats"] $
    smartBorders $
      limitWindows 20 simplestFloat

tall =
  renamed [Replace "tall"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 12 $
              mySpacing 8 $
                ResizableTall 1 (3 / 100) (1 / 2) []

magnify =
  renamed [Replace "magnify"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            magnifier $
              limitWindows 12 $
                mySpacing 8 $
                  ResizableTall 1 (3 / 100) (1 / 2) []

-- monocle =
--   renamed [Replace "monocle"] $
--     smartBorders $
--       windowNavigation $
--         addTabs shrinkText myTabTheme $
--           subLayout [] (smartBorders Simplest) $
--             limitWindows 20 Full

-- grid =
--   renamed [Replace "grid"] $
--     smartBorders $
--       windowNavigation $
--         addTabs shrinkText myTabTheme $
--           subLayout [] (smartBorders Simplest) $
--             limitWindows 12 $
--               mySpacing 8 $
--                 mkToggle (single MIRROR) $
--                   Grid (16 / 10)

-- spirals =
--   renamed [Replace "spirals"] $
--     smartBorders $
--       windowNavigation $
--         addTabs shrinkText myTabTheme $
--           subLayout [] (smartBorders Simplest) $
--             mySpacing' 8 $
--               spiral (6 / 7)

-- threeCol =
--   renamed [Replace "threeCol"] $
--     smartBorders $
--       windowNavigation $
--         addTabs shrinkText myTabTheme $
--           subLayout [] (smartBorders Simplest) $
--             limitWindows 7 $
--               ThreeCol 1 (3 / 100) (1 / 2)

-- threeRow =
--   renamed [Replace "threeRow"] $
--     smartBorders $
--       windowNavigation $
--         addTabs shrinkText myTabTheme $
--           subLayout [] (smartBorders Simplest) $
--             limitWindows 7
--             -- Mirror takes a layout and rotates it by 90 degrees.
--             -- So we are applying Mirror to the ThreeCol layout.
--             $
--               Mirror $
--                 ThreeCol 1 (3 / 100) (1 / 2)

tabs =
  renamed [Replace "tabs"]
  -- I cannot add spacing to this layout because it will
  -- add spacing between window and tabs which looks bad.
  $
    tabbed shrinkText myTabTheme

-- tallAccordion =
--   renamed [Replace "tallAccordion"] $
--     Accordion

-- wideAccordion =
--   renamed [Replace "wideAccordion"] $
--     Mirror Accordion

-- setting colors for tabs layout and tabs sublayout.
myTabTheme =
  def
    { fontName = myFont,
      activeColor = "#46d9ff",
      inactiveColor = "#313846",
      activeBorderColor = "#46d9ff",
      inactiveBorderColor = "#282c34",
      activeTextColor = "#282c34",
      inactiveTextColor = "#d0d0d0"
    }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme =
  def
    { swn_font = "xft:Ubuntu:bold:size=60",
      swn_fade = 1.0,
      swn_bgcolor = "#1c1f24",
      swn_color = "#ffffff"
    }

-- The layout hook
myLayoutHook =
  avoidStruts $
    mouseResize $
      windowArrange $
        T.toggleLayouts floats $
          mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout =
      withBorder
        myBorderWidth
        tall
        ||| magnify
        ||| tabs

{-
  Disabled layouts
||| floats
||| monocle
||| grid
||| spirals
||| threeCol
||| threeRow
||| tallAccordion
||| wideAccordion
-}

{-
  Keys config
    The Xmonad.Util.EZConfig module which allows keybindings to be written in simpler, emacs-like format.
    The Super/Windows key is ‘M’ (the modkey).  The ALT key is ‘M1’.  SHIFT is ‘S’ and CTR is ‘C’.
-}
myKeys =
  [ --
    --Xmonad
    ("M-C-r", spawn "xmonad --recompile"), -- Recompiles xmonad
    ("M-S-r", spawn "xmonad --restart"), -- Restarts xmonad
    -- ("M-S-w", io exitSuccess), -- Quits xmonad
    --
    -- Useful programs to have a keybinding for launch
    ("M-<Return>", spawn myTerminal),
    ("M-b", spawn (myBrowser ++ " www.google.com")),
    ("M-M1-h", spawn (myTerminal ++ " -e htop")),
    ("M-x", spawn "arcolinux-logout"),
    ("M-e", spawn myFileManager),
    ("M-v", spawn "pavucontrol"),
    --
    -- Rofi
    -- ("M-M1-t", spawn "rofi-theme-selector"),
    ("M-p", spawn "rofi -show window"),
    ("M-S-p", spawn "rofi -show drun"),
    ("M-S-d", spawn "rofi -show run"),
    -- ("M-S-d", spawn "dmenu_run -i -p \"Run: \""), -- Dmenu
    -- ("M-S-d", spawn "dmenu_run -i -nb '#191919' -nf '#fea63c' -sb '#fea63c' -sf '#191919' -fn 'NotoMonoRegular:bold:pixelsize=14'"), -- Dmenu
    --
    -- ((modMask, xK_y), spawn "polybar-msg cmd toggle"),
    -- ((0, xK_F12), spawn "xfce4-terminal --drop-down"),
    -- ((controlMask .|. mod1Mask, xK_Next), spawn "conky-rotate -n"),
    -- ((controlMask .|. mod1Mask, xK_Prior), spawn "conky-rotate -p"),
    -- ((controlMask .|. mod1Mask, xK_o), spawn "$HOME/.xmonad/scripts/picom-toggle.sh"),
    -- ((controlMask .|. mod1Mask, xK_u), spawn "pavucontrol"),
    -- ((mod1Mask, xK_f), spawn "variety -f"),
    -- ((mod1Mask, xK_n), spawn "variety -n"),
    -- ((mod1Mask, xK_p), spawn "variety -p"),
    -- ((mod1Mask, xK_t), spawn "variety -t"),
    -- ((mod1Mask, xK_Up), spawn "variety --pause"),
    -- ((mod1Mask, xK_Down), spawn "variety --resume"),
    -- ((mod1Mask, xK_Left), spawn "variety -p"),
    -- ((mod1Mask, xK_Right), spawn "variety -n"),
    -- ((mod1Mask, xK_F2), spawn "xfce4-appfinder --collapsed"),
    -- ((mod1Mask, xK_F3), spawn "xfce4-appfinder"),
    -- ((mod1Mask .|. shiftMask, xK_f), spawn "variety -f && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&"),
    -- ((mod1Mask .|. shiftMask, xK_n), spawn "variety -n && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&"),
    -- ((mod1Mask .|. shiftMask, xK_p), spawn "variety -p && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&"),
    -- ((mod1Mask .|. shiftMask, xK_t), spawn "variety -t && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&"),
    ("C-M1-<Delete>", spawn "xfce4-taskmanager"),
    --
    -- Kill windows
    ("M-S-c", kill1), -- Kill the currently focused client
    ("M-q", kill1), -- Kill the currently focused client
    ("M-S-q", killAll), -- Kill all windows on current workspace
    ("M-<Escape>", spawn "xkill"),
    --
    -- Workspaces
    ("M-,", prevScreen), -- Switch focus to prev monitor
    ("M-.", nextScreen), -- Switch focus to next monitor
    ("M-S-<Right>", shiftTo Next nonNSP >> moveTo Next nonNSP), -- Shifts focused window to next ws
    ("M-S-<Left>", shiftTo Prev nonNSP >> moveTo Prev nonNSP), -- Shifts focused window to prev ws

    -- Floating windows
    -- TODO: M-f doessnt work?
    -- ("M-f", sendMessage (T.Toggle "floats")), -- Toggles my 'floats' layout
    ("M-t", withFocused $ windows . W.sink), -- Push floating window back to tile
    ("M-S-t", sinkAll), -- Push ALL floating windows to tile

    -- Increase/decrease spacing (gaps)
    -- ("C-M1-j", decWindowSpacing 4), -- Decrease window spacing
    -- ("C-M1-k", incWindowSpacing 4), -- Increase window spacing
    -- ("C-M1-h", decScreenSpacing 4), -- Decrease screen spacing
    -- ("C-M1-l", incScreenSpacing 4), -- Increase screen spacing

    -- Grid Select (CTR-g followed by a key)
    -- ("C-g g", spawnSelected' myAppGrid), -- grid select favorite apps
    -- ("C-g t", goToSelected $ mygridConfig myColorizer), -- goto selected window
    -- ("C-g b", bringSelected $ mygridConfig myColorizer), -- bring selected window

    --
    -- Windows navigation
    ("M-m", windows W.focusMaster), -- Move focus to the master window
    ("M-S-m", windows W.swapMaster), -- Swap the focused window and the master window
    --
    -- Focus windows
    ("M-j", windows W.focusDown), -- Move focus to the next window
    ("M-<Down>", windows W.focusDown), -- Move focus to the next window
    ("M-k", windows W.focusUp), -- Move focus to the prev window
    ("M-<Up>", windows W.focusUp), -- Move focus to the prev window
    --
    -- Swap focused windows
    ("M-S-j", windows W.swapDown), -- Swap focused window with next window
    ("M-S-<Down>", windows W.swapDown), -- Swap focused window with next window
    ("M-S-k", windows W.swapUp), -- Swap focused window with prev window
    ("M-S-<Up>", windows W.swapUp), -- Swap focused window with prev window
    -- TODO
    ("M-<Backspace>", promote), -- Moves focused window to master, others maintain order
    ("M-S-<Tab>", rotSlavesDown), -- Rotate all windows except master and keep focus in place
    ("M-C-<Tab>", rotAllDown), -- Rotate all the windows in the current stack
    --
    -- Layouts
    ("M-<Tab>", sendMessage NextLayout), -- Switch to next layout
    -- TODO
    ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts), -- Toggles noborder/full

    -- TODO Increase/decrease windows in the master pane or the stack
    -- ("M-S-<Up>", sendMessage (IncMasterN 1)), -- Increase # of clients master pane
    -- ("M-S-<Down>", sendMessage (IncMasterN (-1))), -- Decrease # of clients master pane
    -- ("M-C-<Up>", increaseLimit), -- Increase # of windows
    -- ("M-C-<Down>", decreaseLimit), -- Decrease # of windows

    --
    -- Window resizing
    ("M-h", sendMessage Shrink), -- Shrink horiz window width
    ("M-<Left>", sendMessage Shrink), -- Shrink horiz window width
    ("M-l", sendMessage Expand), -- Expand horiz window width
    ("M-<Right>", sendMessage Expand), -- Expand horiz window width
    --
    ("M-M1-j", sendMessage MirrorShrink), -- Shrink vert window width
    ("M-M1-<Down>", sendMessage MirrorShrink), -- Shrink vert window width
    ("M-M1-k", sendMessage MirrorExpand), -- Expand vert window width
    ("M-M1-<Up>", sendMessage MirrorExpand), -- Expand vert window width

    --
    -- This is used to push windows to tabbed sublayouts, or pull them out of it.
    -- ("M-C-h", sendMessage $ pullGroup L),
    -- ("M-C-l", sendMessage $ pullGroup R),
    -- ("M-C-k", sendMessage $ pullGroup U),
    -- ("M-C-j", sendMessage $ pullGroup D),
    -- ("M-C-m", withFocused (sendMessage . MergeAll)),
    -- ("M-C-/", withFocused (sendMessage . UnMergeAll)),
    -- ("M-C-.", onGroup W.focusUp'), -- Switch focus to next tab
    -- ("M-C-,", onGroup W.focusDown'), -- Switch focus to prev tab
    --
    -- TODO Scratchpads
    -- Toggle show/hide these programs.  They run on a hidden workspace.
    -- When you toggle them to show, it brings them to your current workspace.
    -- Toggle them to hide and it sends them back to hidden workspace (NSP).
    -- ("C-s t", namedScratchpadAction myScratchPads "terminal"),
    -- ("C-s m", namedScratchpadAction myScratchPads "mocp"),
    -- ("C-s c", namedScratchpadAction myScratchPads "calculator"),
    --
    -- TODO Set wallpaper with 'feh'. Type 'SUPER+F1' to launch sxiv in the wallpapers directory.
    -- Then in sxiv, type 'C-x w' to set the wallpaper that you choose.
    -- ("M-<F1>", spawn "sxiv -r -q -t -o ~/wallpapers/*"),
    -- ("M-<F2>", spawn "/bin/ls ~/wallpapers | shuf -n 1 | xargs xwallpaper --stretch"),
    -- --  ("M-<F2>", spawn "feh --randomize --bg-fill ~/wallpapers/*"),

    -- TODO Controls for mocp music player (SUPER-u followed by a key)
    ("M-u p", spawn "mocp --play"),
    ("M-u l", spawn "mocp --next"),
    ("M-u h", spawn "mocp --previous"),
    ("M-u <Space>", spawn "mocp --toggle-pause"),
    --
    -- TODO Emacs (CTRL-e followed by a key)
    -- --  ("C-e e", spawn myEmacs),                 -- start emacs
    -- ("C-e e", spawn (myEmacs ++ ("--eval '(dashboard-refresh-buffer)'"))), -- emacs dashboard
    -- ("C-e b", spawn (myEmacs ++ ("--eval '(ibuffer)'"))), -- list buffers
    -- ("C-e d", spawn (myEmacs ++ ("--eval '(dired nil)'"))), -- dired
    -- ("C-e i", spawn (myEmacs ++ ("--eval '(erc)'"))), -- erc irc client
    -- ("C-e m", spawn (myEmacs ++ ("--eval '(mu4e)'"))), -- mu4e email
    -- ("C-e n", spawn (myEmacs ++ ("--eval '(elfeed)'"))), -- elfeed rss
    -- ("C-e s", spawn (myEmacs ++ ("--eval '(eshell)'"))), -- eshell
    -- ("C-e t", spawn (myEmacs ++ ("--eval '(mastodon)'"))), -- mastodon.el
    -- -- ("C-e v", spawn (myEmacs ++ ("--eval '(vterm nil)'"))), -- vterm if on GNU Emacs
    -- ("C-e v", spawn (myEmacs ++ ("--eval '(+vterm/here nil)'"))), -- vterm if on Doom Emacs
    -- -- TODO ("C-e w", spawn (myEmacs ++ ("--eval '(eww \"distrotube.com\")'"))), -- eww browser if on GNU Emacs
    -- ("C-e w", spawn (myEmacs ++ "--eval '(doom/window-maximize-buffer(eww \"distrotube.com\"))'")), -- eww browser if on Doom Emacs
    -- emms is an emacs audio player. I set it to auto start playing in a specific directory.
    -- ("C-e a", spawn (myEmacs ++ ("--eval '(emms)' --eval '(emms-play-directory-tree \"~/Music/Non-Classical/70s-80s/\")'"))),

    --
    -- TODO Multimedia Keys
    -- ("<XF86AudioPlay>", spawn (myTerminal ++ "mocp --play")),
    -- ("<XF86AudioPrev>", spawn (myTerminal ++ "mocp --previous")),
    -- ("<XF86AudioNext>", spawn (myTerminal ++ "mocp --next")),
    -- ("<XF86AudioMute>", spawn "amixer set Master toggle"),
    ("<XF86AudioLowerVolume>", spawn "amixer set Master 3%- unmute"),
    ("<XF86AudioRaiseVolume>", spawn "amixer set Master 3%+ unmute"),
    -- ("<XF86HomePage>", spawn "qutebrowser https://www.youtube.com/c/DistroTube"),
    -- ("<XF86Search>", spawn "dmsearch"),
    -- ("<XF86Mail>", runOrRaise "thunderbird" (resource =? "thunderbird")),
    -- ("<XF86Calculator>", runOrRaise "qalculate-gtk" (resource =? "qalculate-gtk")),
    -- ("<XF86Eject>", spawn "toggleeject"),
    -- TODO Screenshot
    ("<Print>", spawn "dmscrot")
    --
    --
    --
    --
    --

    -- ((mod1Mask .|. shiftMask, xK_u), spawn "wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&"),
    -- ((0, xK_Print), spawn "scrot 'ArcoLinux-%Y-%m-%d-%s_screenshot_$wx$h.jpg' -e 'mv $f $$(xdg-user-dir PICTURES)'"),
    -- ((controlMask, xK_Print), spawn "xfce4-screenshooter"),
    -- ((controlMask .|. shiftMask, xK_Print), spawn "gnome-screenshot -i"),
    -- --MULTIMEDIA KEYS

    -- -- Mute volume
    -- ((0, xF86XK_AudioMute), spawn "amixer -q set Master toggle"),
    -- -- Decrease volume
    -- ((0, xF86XK_AudioLowerVolume), spawn "amixer -q set Master 5%-"),
    -- -- Increase volume
    -- ((0, xF86XK_AudioRaiseVolume), spawn "amixer -q set Master 5%+"),
    -- -- Increase brightness
    -- ((0, xF86XK_MonBrightnessUp), spawn "xbacklight -inc 5"),
    -- -- Decrease brightness
    -- ((0, xF86XK_MonBrightnessDown), spawn "xbacklight -dec 5"),
    -- --  , ((0, xF86XK_AudioPlay), spawn $ "mpc toggle")
    -- --  , ((0, xF86XK_AudioNext), spawn $ "mpc next")
    -- --  , ((0, xF86XK_AudioPrev), spawn $ "mpc prev")
    -- --  , ((0, xF86XK_AudioStop), spawn $ "mpc stop")

    -- ((0, xF86XK_AudioPlay), spawn "playerctl play-pause"),
    -- ((0, xF86XK_AudioNext), spawn "playerctl next"),
    -- ((0, xF86XK_AudioPrev), spawn "playerctl previous"),
    -- ((0, xF86XK_AudioStop), spawn "playerctl stop"),
    -- --  XMONAD LAYOUT KEYS

    -- -- Cycle through the available layout algorithms.
    -- ((modMask, xK_space), sendMessage NextLayout),
    -- --Focus selected desktop
    -- ((mod1Mask, xK_Tab), nextWS),
    -- --Focus selected desktop
    -- ((modMask, xK_Tab), nextWS),
    -- --Focus selected desktop
    -- ((controlMask .|. mod1Mask, xK_Left), prevWS),
    -- --Focus selected desktop
    -- ((controlMask .|. mod1Mask, xK_Right), nextWS),
    -- --  Reset the layouts on the current workspace to default.
    -- ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf),
    -- -- Move focus to the next window.
    -- ((modMask, xK_j), windows W.focusDown),
    -- -- Move focus to the previous window.
    -- ((modMask, xK_k), windows W.focusUp),
    -- -- Move focus to the master window.
    -- ((modMask .|. shiftMask, xK_m), windows W.focusMaster),
    -- -- Swap the focused window with the next window.
    -- ((modMask .|. shiftMask, xK_j), windows W.swapDown),
    -- -- Swap the focused window with the next window.
    -- ((controlMask .|. modMask, xK_Down), windows W.swapDown),
    -- -- Swap the focused window with the previous window.
    -- ((modMask .|. shiftMask, xK_k), windows W.swapUp),
    -- -- Swap the focused window with the previous window.
    -- ((controlMask .|. modMask, xK_Up), windows W.swapUp),
    -- -- Shrink the master area.
    -- ((controlMask .|. shiftMask, xK_h), sendMessage Shrink),
    -- -- Expand the master area.
    -- ((controlMask .|. shiftMask, xK_l), sendMessage Expand),
    -- -- Push window back into tiling.
    -- ((controlMask .|. shiftMask, xK_t), withFocused $ windows . W.sink),
    -- -- Increment the number of windows in the master area.
    -- ((controlMask .|. modMask, xK_Left), sendMessage (IncMasterN 1)),
    -- -- Decrement the number of windows in the master area.
    -- ((controlMask .|. modMask, xK_Right), sendMessage (IncMasterN (-1)))
  ]
  where
    -- The following lines are needed for named scratchpads.
    nonNSP = WSIs (return (\ws -> W.tag ws /= "NSP"))
    nonEmptyNonNSP = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

main :: IO ()
main = do
  -- Launching three instances of xmobar on their monitors.
  -- xmproc0 <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc0"
  -- xmproc1 <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobarrc1"
  -- xmproc2 <- spawnPipe "xmobar -x 2 $HOME/.config/xmobar/xmobarrc2"
  -- the xmonad, ya know...what the WM is named after!
  xmonad $
    ewmh
      def
        { modMask = myModMask,
          terminal = myTerminal,
          startupHook = myStartupHook,
          manageHook = myManageHook <+> manageDocks,
          -- Add `fullscreenEventHook` to `handleEventHook` to enable fullscreen support
          -- on things like YouTube/Netflix.
          -- This works perfect on SINGLE monitor systems. On multi-monitor systems,
          -- it adds a border around the window if screen does not have focus. So, the solution
          -- is to use a keybinding to toggle fullscreen noborders instead. e.g: (M-<Space>)
          handleEventHook = docksEventHook <+> fullscreenEventHook,
          layoutHook = gaps [(U, 35), (D, 5), (R, 5), (L, 5)] $ showWName' myShowWNameTheme myLayoutHook,
          workspaces = myWorkspaces,
          borderWidth = myBorderWidth,
          normalBorderColor = myNormColor,
          focusedBorderColor = myFocusColor,
          focusFollowsMouse = myFocusFollowsMouse
          -- TODO logHook
          -- logHook =
          --   dynamicLogWithPP $
          --     namedScratchpadFilterOutWorkspacePP $
          --       xmobarPP
          --         { -- the following variables beginning with 'pp' are settings for xmobar.
          --           ppOutput = \x ->
          --             hPutStrLn xmproc0 x -- xmobar on monitor 1
          --               >> hPutStrLn xmproc1 x -- xmobar on monitor 2
          --               >> hPutStrLn xmproc2 x, -- xmobar on monitor 3
          --           ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]", -- Current workspace
          --           ppVisible = xmobarColor "#98be65" "" . clickable, -- Visible but not current workspace
          --           ppHidden = xmobarColor "#82AAFF" "" . wrap "*" "" . clickable, -- Hidden workspaces
          --           ppHiddenNoWindows = xmobarColor "#c792ea" "" . clickable, -- Hidden workspaces (no windows)
          --           ppTitle = xmobarColor "#b3afc2" "" . shorten 60, -- Title of active window
          --           ppSep = "<fc=#666666> <fn=1>|</fn> </fc>", -- Separator character
          --           ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!", -- Urgent workspace
          --           ppExtras = [windowCount], -- # of windows current workspace
          --           ppOrder = \(ws : l : t : ex) -> [ws, l] ++ ex ++ [t] -- order of things in xmobar
          --         }
        }
      `additionalKeysP` myKeys
