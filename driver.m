#include "driver.h"
#include "_cgo_export.h"
#include "mac.h"
#include "menu.h"

@implementation DriverDelegate
- (instancetype)init {
  self.dock = [[NSMenu alloc] initWithTitle:@""];
  return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  onLaunch();
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
  onFocus();
}

- (void)applicationDidResignActive:(NSNotification *)aNotification {
  onBlur();
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender
                    hasVisibleWindows:(BOOL)flag {
  onReopen(flag);
  return YES;
}

- (BOOL)application:(NSApplication *)theApplication
           openFile:(NSString *)filename {
  onFileOpen((char *)filename.UTF8String);
  return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:
    (NSApplication *)sender {
  return onTerminate();
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  onFinalize();
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
  return self.dock;
}
@end

const void *Driver_Init() {
  [NSApplication sharedApplication];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  [NSApp activateIgnoringOtherApps:YES];

  DriverDelegate *delegate = [[DriverDelegate alloc] init];
  NSApp.delegate = delegate;

  return CFBridgingRetain(delegate);
}

void Driver_Run() { [NSApp run]; }

void Driver_Terminate() { [NSApp terminate:NSApp]; }

const char *Driver_Resources() {
  NSBundle *mainBundle = [NSBundle mainBundle];
  return mainBundle.resourcePath.UTF8String;
}

void Driver_SetAppMenu(const void *menuPtr) {
  Menu *menu = (__bridge Menu *)menuPtr;

  defer(NSApp.mainMenu = menu.Root;);
}

void Driver_SetDockMenu(const void *dockPtr) {
  Menu *menu = (__bridge Menu *)dockPtr;
  DriverDelegate *delegate = NSApp.delegate;
  delegate.dock = menu.Root;
}

void Driver_SetDockIcon(const char *path) {
  NSString *p = [NSString stringWithUTF8String:path];

  if (p.length != 0) {
    NSApp.applicationIconImage = [[NSImage alloc] initByReferencingFile:p];
    return;
  }

  NSApp.applicationIconImage = nil;
}

void Driver_SetDockBadge(const char *str) {
  [NSApp.dockTile setBadgeLabel:[NSString stringWithUTF8String:str]];
}