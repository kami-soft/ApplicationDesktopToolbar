# ApplicationDesktopToolbar
Delphi implementation of Windows [Application Desktop Toolbar](https://docs.microsoft.com/en-us/windows/win32/shell/application-desktop-toolbars)

This project is inheritor of [TAppBar component]( https://torry.net/authorsmore.php?id=696 ) 
with lot of modifications for support latest Delphi versions (tested on XE2..10.2),

Remove hints & warnings, use new constructions, add **multi-monitor support**, simplify code.

Source Readme file still exists (AppBar14.txt)

How to use:  
1. Add AppBar unit to uses in interface section **after** VCL.Forms.
2. Set BorderStyle to bsNone (you can leave it as is, but bsNone is recommended value)

properties
- Edge : TAppBarEdge. Edge to dock on. It can assume one of the following values: abeLeft, abeTop, abeRight, abeBottom, abeUnknown, abeFloat.
- Autohide: boolean. Used with docked form (Edge = abeLeft..abeBottom). If True then form minimizes when another window activated
- AppbarWidth and AppbarHeight: integer. Used to control size of docked form.
- DragByMouse: Boolean. Allow / disable drag form by mouse. This property also used to automatic docking form when mouse moved too close to edge.

events
- OnEdgeChange: used to allow / decline change Edge property