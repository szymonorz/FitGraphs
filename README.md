# DataMobileUI

## How to run

Either import into Xcode and hope/pray it works

or

use the poorly written Makefile (make sure to adjust `IOS_VERSION`, `PLATFORM`,`EMULATOR_NAME` to your setup/preferences)

```bash
# first boot the emulator
make boot
# then build and run the app
make 
```

There is no debugging mode in Makefile because I cannot be bothered with lldb rn 