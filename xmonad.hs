  -- Base
import XMonad
import System.Directory
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

    -- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

    -- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks -- (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory

    -- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

   -- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig -- (additionalKeys)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run -- (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

import System.Exit

myFont :: String
myFont = "xft:JetBrains Mono:style=Regular:size=10:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask        -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "urxvt"    -- Sets default terminal

myBrowser :: String
myBrowser = "firefox "  -- Sets qutebrowser as browser

myBorderWidth :: Dimension
myBorderWidth = 2           -- Sets border width for windows

myNormalBorderColor :: String
myNormalBorderColor = "#a89984"

myFocusedBorderColor :: String
myFocusedBorderColor = "#FE8019"

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
    spawnOnce "urxvt -q -o -f &" -- urxvt daemon for better performance  
    spawnOnce "nitrogen --restore &"
    spawnOnce "picom -f --config /home/santiago/.config/picom/picom.conf &"
    
    -- Workspace layout on the monitors
    screenWorkspace 2 >>= flip whenJust (windows . W.view) -- Focus the second screen.
    windows $ W.greedyView "tv" -- Force the second screen to "tv"

    screenWorkspace 1 >>= flip whenJust (windows . W.view) -- Focus the first screen.
    windows $ W.greedyView "docs" -- Force the first screen to "main"
    
    screenWorkspace 0 >>= flip whenJust (windows . W.view) -- Focus the main screen again.

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing' 8
           $ ResizableTall 1 (3/100) (1/2) []
magnify  = renamed [Replace "magnify"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ magnifier
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ smartBorders
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
spirals  = renamed [Replace "spirals"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing' 8
           $ spiral (6/7)
threeCol = renamed [Replace "threeCol"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme
tallAccordion  = renamed [Replace "tallAccordion"]
           $ Accordion
wideAccordion  = renamed [Replace "wideAccordion"]
           $ Mirror Accordion

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = "#46d9ff"
                 , inactiveColor       = "#313846"
                 , activeBorderColor   = "#46d9ff"
                 , inactiveBorderColor = "#282c34"
                 , activeTextColor     = "#282c34"
                 , inactiveTextColor   = "#d0d0d0"
                 }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Roboto Mono:bold:size=60"
    , swn_fade              = 1.0
    , swn_bgcolor           = "#1d2021"
    , swn_color             = "#ebdbb2"
    }

-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     withBorder myBorderWidth tall
                                 ||| magnify
                                 ||| noBorders monocle
                                 ||| floats
                                 ||| noBorders tabs
                                 ||| grid
                                 ||| spirals
                                 ||| threeCol
                                 ||| threeRow
                                 ||| tallAccordion
                                 ||| wideAccordion

myWorkspaces = ["main", "dev", "www", "gfx", "5", "6", "7", "8", "docs", "tv"]

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out the full
     -- name of my workspaces and the names would be very long if using clickable workspaces.
     [ className =? "confirm"         --> doFloat
     , className =? "file_progress"   --> doFloat
     , className =? "dialog"          --> doFloat
     , className =? "download"        --> doFloat
     , className =? "error"           --> doFloat
     , className =? "Gimp"            --> doFloat
     , className =? "notification"    --> doFloat
     , className =? "pinentry-gtk-2"  --> doFloat
     , className =? "splash"          --> doFloat
     , className =? "toolbar"         --> doFloat
     , className =? "Pavucontrol"     --> doFloat
     , className =? "nemo"            --> doFloat
     , title =? "Visual Studio Code"  --> doShift ( myWorkspaces !! 1 )
     , title =? "Mozilla Firefox"     --> doShift ( myWorkspaces !! 2 )
     , className =? "Gimp"            --> doShift ( myWorkspaces !! 3 )
     , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     , isFullscreen -->  doFullFloat
     ] 

-- Key Bindings
myKeys = 
    -- Launch terminal
    [ ((myModMask, xK_Return), spawn myTerminal)
    
    -- Launch dmenu
    , ((myModMask, xK_d), spawn "dmenu_run")

    -- Launch browser
    , ((myModMask, xK_b), spawn "firefox")

    -- Lauch vs-code
    , ((myModMask, xK_c), spawn "code")

    -- Launch nemo
    , ((myModMask, xK_f), spawn "nemo")

    -- Close focused window
    , ((myModMask .|. shiftMask, xK_q), kill)

    -- Quit xmonad
    , ((myModMask .|. shiftMask, xK_c), io (exitWith ExitSuccess))

    -- Volume control
    , ((myModMask, 0xffbf), spawn "amixer -q sset Master 2%-")
    , ((myModMask, 0xffc0), spawn "amixer -q sset Master 2%+")
    , ((myModMask, 0xffc1), spawn "amixer set Master toggle")

    -- Pulse audio volume control
    , ((myModMask, xK_v), spawn "pavucontrol")
    ]
    ++
    [((m .|. myModMask, k), windows $ f i) -- To replace greedyView with regular view
         | (i, k) <- zip myWorkspaces [xK_1 .. xK_9]
         , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
     
main :: IO ()
main = do
    xmproc <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc"
    xmproctv <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobarrc-tv"
    xmprocportrait <- spawnPipe "xmobar -x 2 $HOME/.config/xmobar/xmobarrc-portrait"

    -- the xmonad, ya know...what the WM is named after!
    xmonad $ ewmh def
        { manageHook         = myManageHook <+> manageDocks
        , handleEventHook    = docksEventHook
                               -- Uncomment this line to enable fullscreen support on things like YouTube/Netflix.
                               -- This works perfect on SINGLE monitor systems. On multi-monitor systems,
                               -- it adds a border around the window if screen does not have focus. So, my solution
                               -- is to use a keybinding to toggle fullscreen noborders instead.  (M-<Space>)
                               -- <+> fullscreenEventHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , logHook = workspaceHistoryHook <+> dynamicLogWithPP xmobarPP
            { ppOutput = \x -> hPutStrLn xmproc x >> hPutStrLn xmproctv x >> hPutStrLn xmprocportrait x
            , ppCurrent = xmobarColor "#98971a" "" . wrap "[" "]" -- current workspace
            , ppVisible = xmobarColor "#b8bb26" ""                -- visible but not current workspace
            , ppHidden = xmobarColor "#bdae93" ""                 -- hidden workspaces
            , ppHiddenNoWindows = xmobarColor "#504945" ""        -- hidden workspaces (no windows)
            , ppTitle = xmobarColor "#b3afc2" "" . shorten 10     -- title of active window
            , ppSep = "<fc=#32302f> <fn=1>|</fn> </fc>"           -- separators
            , ppUrgent = xmobarColor "#c45500" "" . wrap "!" "!"  -- urgent workspace
            , ppOrder = \(ws:l:t:ex) -> ws : ex -- extra [ws,l]++ex++[t]
            }
        } `additionalKeys` myKeys
