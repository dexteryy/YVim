
if has("gui_macvim")

  macm File.New\ Window                           key= <D-N> action=newWindow:
  macm File.New\ Tab                              key= <D-n>
  macm File.Open\.\.\.                            key= <nop>
  macm File.Open\ Tab\.\.\.<Tab>:tabnew           key= <nop>
  "macm File.Close\ Window<Tab>:qa                key= <D-W>
  macm File.Close                                 key= <nop>
  "macm File.Save<Tab>:w                          key= <D-s>
  "macm File.Save\ All                            key= <D-M-s> alt=YES
  "macm File.Save\ As\.\.\.<Tab>:sav              key= <D-S>
  macm File.Print                                 key= <nop>

  macm Edit.Undo<Tab>u                            key= <D-z> action=undo:
  macm Edit.Redo<Tab>^R                           key= <D-y> action=redo:
  "macm Edit.Cut<Tab>"+x                          key= <D-x> action=cut:
  "macm Edit.Copy<Tab>"+y                         key= <D-c> action=copy:
  "macm Edit.Paste<Tab>"+gP                       key= <D-v> action=paste:
  "macm Edit.Select\ All<Tab>ggVG                 key= <D-a> action=selectAll:
  macm Edit.Find.Find\.\.\.                       key= <nop>
  macm Edit.Find.Find\ Next                       key= <nop>
  macm Edit.Find.Find\ Previous                   key= <nop>
  macm Edit.Find.Use\ Selection\ for\ Find        key= <nop>
  "macm Edit.Font.Bigger                          key= <D-=> action=fontSizeUp:
  "macm Edit.Font.Smaller                         key= <D--> action=fontSizeDown:
  "macm Edit.Special\ Characters\.\.\.             key= <D-C-Space> action=orderFrontCharacterPalette:

  "macm Tools.Spelling.To\ Next\ error<Tab>]s      key= <nop>
  macm Tools.Spelling.Suggest\ Corrections<Tab>z= key= <nop>
  macm Tools.Make<Tab>:make                       key= <nop>
  macm Tools.List\ Errors<Tab>:cl                 key= <nop>
  macm Tools.Next\ Error<Tab>:cn                  key= <nop>
  macm Tools.Previous\ Error<Tab>:cp              key= <nop>
  macm Tools.Older\ List<Tab>:cold                key= <nop>
  macm Tools.Newer\ List<Tab>:cnew                key= <nop>

  macm Window.Minimize                            key= <nop>
  macm Window.Minimize\ All                       key= <nop>
  macm Window.Zoom                                key= <nop>
  macm Window.Zoom\ All                           key= <nop>
  macm Window.Toggle\ Full\ Screen\ Mode          key= <nop>
  "macm Window.Select\ Next\ Tab                  key= <D-}>
  "macm Window.Select\ Previous\ Tab              key= <D-{>

  macm Help.MacVim\ Help                          key= <nop>

endif
