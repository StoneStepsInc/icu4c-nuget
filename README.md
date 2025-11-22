## ICU4C Nuget Package

This package contains dynamic ICU4C libraries and header files
for the x64 platform, built with Visual C++ 2022, against
Debug/Release MT/DLL MSVC CRT.

Visit ICU4C project for ICU4C library documentation:

https://unicode-org.github.io/icu/

## Package Configuration

This package contains only dynamic libraries for platforms listed
above.

The ICU4C dynamic libraries from this package will appear within
the installation target project after the package is installed.
The solution may need to be reloaded to make libraries visible.
Both, debug and release libraries will be listed in the project,
but only the one appropriate for the currently selected
configuration will be included in the build. These libraries
may be moved into solution folders after the installation (e.g.
`lib/Debug` and `lib/Release`). The data library (`icudt.lib`)
is not configuration specific, and can be placed under `lib`.

Note that the ICU4C library path in this package will be selected
as `Debug` or `Release` based on whether the selected configuration
is designated as a development or as a release configuration via
the standard Visual Studio property called `UseDebugLibraries`.
Additional configurations copied from the standard ones will
inherit this property. 

Do not install this package if your projects use debug configurations
without `UseDebugLibraries`. Note that CMake-generated Visual Studio
projects may not emit this property.

See `StoneSteps.ICU4C.VS2022.Dynamic.props` and
`StoneSteps.ICU4C.VS2022.Dynamic.targets`
for specific package configuration details and file locations.

## ICU4C Data

This package contains ICU4C data in `icudt78l.dll`, which is
included into the project via the `icudt.lib` import library.
Remove `icudt.lib` from the project if you would like to load
custom data via `u_setDataDirectory` on application start-up.

See this page for additional information about ICU data.

https://unicode-org.github.io/icu/userguide/icu_data/

## Package Version

### Package Revision

Nuget packages lack package revision and in order to repackage
the same upstream software version, such as ICU4C v78.1.0, the
4th component of the Nuget version is used to track the Nuget
package revision.

Nuget package revision is injected outside of the Nuget package
configuration, during the package build process, and is not present
in the package specification file.

Specifically, `nuget.exe` is invoked with `-Version=78.1.0.123` to
build a package with the revision `123`.

### Version Locations

ICU4C version is located in a few places in this repository and
needs to be changed in all of them for a new version of ICU4C.

  * nuget/StoneSteps.ICU4C.VS2022.Dynamic.nuspec (`version`)
  * devops/make-package.bat (`PKG_VER`, `PKG_VER_ABBR`)
  * .github/workflows/nuget-ICU4C-56.1.0.yml (`name`, `PKG_VER`,
    `PKG_REV`, `ICU4C_FNAME`)

In the GitHub workflow YAML, `PKG_REV` must be reset to `1` (one)
every time ICU4C version is changed. The workflow file must
be renamed with the new version in the name. This is necessary
because GitHub maintains build numbers per workflow file name.

For local builds package revision is supplied on the command line
and should be specified as `1` (one) for a new version of ICU4C.

### GitHub Build Number

Build number within the GitHub workflow YAML is maintained in an
unconventional way because of the lack of build maturity management
between GitHub and Nuget.

For example, using a build management system, such as Artifactory,
every build would generate a Nuget package with the same version
and package revision for the upcoming release and build numbers
would be tracked within the build management system. A build that
was successfully tested would be promoted to the production Nuget
repository without generating a new build.

Without a build management system, the GitHub workflow in this
repository uses the pre-release version as a surrogate build
number for builds that do not publish packages to nuget.org, so
these builds can be downloaded and tested before the final build
is made and published to [nuget.org][]. This approach is not
recommended for robust production environments because even
though the final published package is built from the exact same
source, the build process may still potentially introduce some
unknowns into the final package (e.g. build VM was updated).

## Building Package Locally

You can build a Nuget package locally with `make-package.bat`
located in `devops`. This script expects VS2022 Community Edition
installed in the default location. If you have other edition of
Visual Studio, edit the file to use the correct path to the
`vcvarsall.bat` file.

Run `make-package.bat` from the repository root directory with
a package revision as the first argument. There is no provision
to manage build numbers from the command line and other tools
should be used for this.

## Sample Application

A Visual Studio project is included in this repository under
`sample-ICU4C` to test the Nuget package built by this project.

This application does not do anything useful and merely calls
ICU4C functions to verify that the package is installed
properly for all platforms and configurations.

[nuget.org]: https://www.nuget.org/packages/StoneSteps.ICU4C.VS2022.Dynamic/
