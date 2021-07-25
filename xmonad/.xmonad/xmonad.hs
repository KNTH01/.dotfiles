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

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

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

{-
  Window manipulations
-}
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
    my3Shifts = []
    my4Shifts = ["Spotify"]
    my5Shifts = ["Telegram", "WhatsApp", "Signal", "discord"]
    my6Shifts = ["vlc", "mpv"]
    my7Shifts = []
    my8Shifts = []
    my9Shifts = []
    my10Shifts = ["Virtualbox"]

{-
  Layouts
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

tabs = renamed [Replace "tabs"] $ tabbed shrinkText myTabTheme

tallAccordion = renamed [Replace "tallAccordion"] Accordion

wideAccordion = renamed [Replace "wideAccordion"] $ Mirror Accordion

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
--    You can specify and transform your layouts by modifying these values.
--    If you change layout bindings be sure to use 'mod-shift-space' after
--    restarting (with 'mod-q') to reset your layout state to the new
--    defaults, as xmonad preserves your old layout settings by default.
--
--    The available layouts.  Note that each layout is separated by |||,
--    which denotes layout choice.
myLayoutHook =
  avoidStruts $
    mouseResize $
      windowArrange $
        mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout =
      withBorder
        myBorderWidth
        tall
        ||| magnify
        ||| tabs
        ||| tallAccordion
        ||| wideAccordion

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
    ("M-S-w", io exitSuccess), -- Quits xmonad
    --
    -- Useful programs to have a keybinding for launch
    ("M-<Return>", spawn myTerminal),
    ("M-b", spawn (myBrowser ++ " www.google.com")),
    ("M-M1-h", spawn (myTerminal ++ " -e htop")),
    ("M-x", spawn "arcolinux-logout"),
    ("M-e", spawn myFileManager),
    ("M-v", spawn "pavucontrol"),
    ("C-M1-<Delete>", spawn "xfce4-taskmanager"),
    ("M-S-b", spawn "polybar-msg cmd toggle"),
    -- ((controlMask .|. mod1Mask, xK_Next), spawn "conky-rotate -n"),
    -- ((controlMask .|. mod1Mask, xK_Prior), spawn "conky-rotate -p"),
    --
    -- rofi
    ("M-p", spawn "rofi -show window"),
    ("M-S-p", spawn "rofi -show drun -drun-icon-theme \"candy-icons\""),
    ("M-S-d", spawn "rofi -show run"),
    ("M-M1-t", spawn "rofi-theme-selector"),
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
    ("M1-<Tab>", nextWS),
    ("M1-S-<Tab>", prevWS),
    ("C-M1-<Right>", nextWS),
    ("C-M1-<Left>", prevWS),
    --
    -- Floating windows
    ("M-t", withFocused $ windows . W.sink), -- Push floating window back to tile
    ("M-S-t", sinkAll), -- Push ALL floating windows to tile
    --
    -- Master Windows
    ("M-m", windows W.focusMaster), -- Move focus to the master window
    ("M-S-m", windows W.swapMaster), -- Swap the focused window and the master window
    ("M-<Backspace>", promote), -- Moves focused window to master, others maintain order
    ("C-M-<Up>", sendMessage (IncMasterN 1)), -- Increase # of clients master pane
    ("C-M-<Down>", sendMessage (IncMasterN (-1))), -- Decrease # of clients master pane
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
    -- Rotate windows
    ("M-S-<Tab>", rotSlavesDown), -- Rotate all windows except master and keep focus in place
    ("M-C-<Tab>", rotAllDown), -- Rotate all the windows in the current stack
    --
    -- Layouts
    ("M-<Tab>", sendMessage NextLayout), -- Cycle through the available layout algorithms
    ("M-f", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts), -- Toggles noborder/full
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
    -- TODO Toggle show/hide these programs.  They run on a hidden workspace.
    -- When you toggle them to show, it brings them to your current workspace.
    -- Toggle them to hide and it sends them back to hidden workspace (NSP).
    -- ("C-s t", namedScratchpadAction myScratchPads "terminal"),
    -- ("C-s m", namedScratchpadAction myScratchPads "mocp"),
    -- ("C-s c", namedScratchpadAction myScratchPads "calculator"),
    --
    -- Multimedia Keys
    ("<XF86AudioPlay>", spawn "playerctl play-pause"),
    ("<XF86AudioPrev>", spawn "playerctl next"),
    ("<XF86AudioNext>", spawn "playerctl previous"),
    ("<xF86AudioStop>", spawn "playerctl stop"),
    ("<XF86AudioMute>", spawn "amixer set Master toggle"),
    ("<XF86AudioLowerVolume>", spawn "amixer set Master 3%- unmute"),
    ("<XF86AudioRaiseVolume>", spawn "amixer set Master 3%+ unmute"),
    ("<XF86Calculator>", runOrRaise "qalculate-gtk" (resource =? "qalculate-gtk")),
    ("<XF86Eject>", spawn "toggleeject"),
    ("<xF86MonBrightnessUp>", spawn "xbacklight -inc 3"), -- Increase brightness
    ("<xF86MonBrightnessDown>", spawn "xbacklight -dec 3"), -- Decrease brightness
    --
    -- TODO Screenshot
    ("<Print>", spawn "dmscrot")
    -- ((controlMask, xK_Print), spawn "xfce4-screenshooter"),
    -- ((controlMask .|. shiftMask, xK_Print), spawn "gnome-screenshot -i"),
  ]
  where
    -- The following lines are needed for named scratchpads.
    nonNSP = WSIs (return (\ws -> W.tag ws /= "NSP"))
    nonEmptyNonNSP = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

myKeys2 conf@XConfig {XMonad.modMask = modm} =
  M.fromList
    [ --
      -- reset to default layout
      -- TODO
      ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)
    ]

defaults =
  def
    { modMask = myModMask,
      terminal = myTerminal,
      startupHook = myStartupHook,
      manageHook = myManageHook <+> manageDocks,
      handleEventHook = docksEventHook <+> fullscreenEventHook,
      layoutHook = gaps [(U, 35), (D, 5), (R, 5), (L, 5)] $ showWName' myShowWNameTheme myLayoutHook,
      workspaces = myWorkspaces,
      borderWidth = myBorderWidth,
      normalBorderColor = myNormColor,
      focusedBorderColor = myFocusColor,
      focusFollowsMouse = myFocusFollowsMouse,
      clickJustFocuses = myClickJustFocuses
      -- keys = myKeys2 -- need to play with myBaseConfig... TODO later
    }
    `additionalKeysP` myKeys

main :: IO ()
main = xmonad $ ewmh defaults
