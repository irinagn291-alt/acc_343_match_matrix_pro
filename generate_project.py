from pathlib import Path
root=Path(__file__).parent
objects={}
def add(key,body): objects[key]=body; return key
def uid(n): return f'{n:024X}'
project,main,products,target,product,sources,resources,frameworks,configs,pconfigs=[uid(i) for i in range(1,11)]
refs=[]; builds=[]
for n,name in enumerate(['App.swift','Domain.swift','Store.swift']):
 ref=add(uid(100+n),f'isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Sources/{name}; sourceTree = "<group>";')
 builds.append(add(uid(200+n),f'isa = PBXBuildFile; fileRef = {ref};')); refs.append(ref)
add(main,f'isa = PBXGroup; children = ({",".join(refs+[products])}); sourceTree = "<group>";')
add(products,f'isa = PBXGroup; children = ({product}); name = Products; sourceTree = "<group>";')
add(product,'isa = PBXFileReference; explicitFileType = wrapper.application; path = MatchMatrix.app; sourceTree = BUILT_PRODUCTS_DIR;')
add(sources,f'isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({",".join(builds)}); runOnlyForDeploymentPostprocessing = 0;')
for key,isa in [(resources,'PBXResourcesBuildPhase'),(frameworks,'PBXFrameworksBuildPhase')]: add(key,f'isa = {isa}; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0;')
add(target,f'isa = PBXNativeTarget; buildConfigurationList = {configs}; buildPhases = ({sources},{frameworks},{resources}); buildRules = (); dependencies = (); name = MatchMatrix; productName = MatchMatrix; productReference = {product}; productType = "com.apple.product-type.application";')
add(project,f'isa = PBXProject; attributes = {{ LastUpgradeCheck = 1600; }}; buildConfigurationList = {pconfigs}; compatibilityVersion = "Xcode 14.0"; developmentRegion = en_GB; knownRegions = (en_GB,Base); mainGroup = {main}; productRefGroup = {products}; projectDirPath = ""; projectRoot = ""; targets = ({target});')
for key,base in [(configs,300),(pconfigs,400)]:
 ids=[]
 for i,name in enumerate(['Debug','Release']):
  settings=''
  if key==configs: settings='PRODUCT_BUNDLE_IDENTIFIER = com.matchmatrix.analytics; PRODUCT_NAME = "$(TARGET_NAME)"; GENERATE_INFOPLIST_FILE = YES; INFOPLIST_KEY_CFBundleDisplayName = "Match Matrix"; INFOPLIST_KEY_UILaunchScreen_Generation = YES; INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES; INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"; TARGETED_DEVICE_FAMILY = "1,2"; SWIFT_VERSION = 6.0; IPHONEOS_DEPLOYMENT_TARGET = 17.0; SDKROOT = iphoneos; CODE_SIGN_STYLE = Automatic; SWIFT_STRICT_CONCURRENCY = complete;'
  else: settings='CLANG_ENABLE_MODULES = YES; SWIFT_OPTIMIZATION_LEVEL = '+ ('"-Onone"' if i==0 else '"-O"')+';'
  if name == 'Debug': settings += ' SWIFT_ACTIVE_COMPILATION_CONDITIONS = "$(inherited) DEBUG";'
  ids.append(add(uid(base+i),f'isa = XCBuildConfiguration; buildSettings = {{{settings}}}; name = {name};'))
 add(key,f'isa = XCConfigurationList; buildConfigurations = ({",".join(ids)}); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;')
# External UI runner target.
ut,up,us,uc,ur,ub=[uid(i) for i in range(500,506)]
add(ur,'isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Tests/UITests.swift; sourceTree = "<group>";')
add(ub,f'isa = PBXBuildFile; fileRef = {ur};')
objects[main]=objects[main].replace('children = (',f'children = ({ur},')
add(up,'isa = PBXFileReference; explicitFileType = wrapper.cfbundle; path = MatchMatrixUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR;')
objects[products]=objects[products].replace('children = (',f'children = ({up},')
add(us,f'isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({ub}); runOnlyForDeploymentPostprocessing = 0;')
add(ut,f'isa = PBXNativeTarget; buildConfigurationList = {uc}; buildPhases = ({us}); buildRules = (); dependencies = (); name = MatchMatrixUITests; productName = MatchMatrixUITests; productReference = {up}; productType = "com.apple.product-type.bundle.ui-testing";')
for i,name in enumerate(['Debug','Release']):
 add(uid(510+i),f'isa = XCBuildConfiguration; name = {name}; buildSettings = {{PRODUCT_BUNDLE_IDENTIFIER = com.matchmatrix.analytics.uitests; PRODUCT_NAME = "$(TARGET_NAME)"; GENERATE_INFOPLIST_FILE = YES; SWIFT_VERSION = 6.0; IPHONEOS_DEPLOYMENT_TARGET = 17.0; SDKROOT = iphoneos; TARGETED_DEVICE_FAMILY = "1,2"; TEST_TARGET_NAME = MatchMatrix; CODE_SIGNING_ALLOWED = NO; }};')
add(uc,f'isa = XCConfigurationList; buildConfigurations = ({uid(510)},{uid(511)}); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;')
objects[project]=objects[project].replace(f'targets = ({target})',f'targets = ({target},{ut})')
scheme=root/'MatchMatrix.xcodeproj/xcshareddata/xcschemes'
scheme.mkdir(parents=True,exist_ok=True)
def reference(t,n): return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{t}" BuildableName="{n}" BlueprintName="{n.split(".")[0]}" ReferencedContainer="container:MatchMatrix.xcodeproj"/>'
(scheme/'MatchMatrix.xcscheme').write_text(f'''<?xml version="1.0" encoding="UTF-8"?><Scheme LastUpgradeVersion="1600" version="1.3"><BuildAction parallelizeBuildables="NO" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{reference(target,"MatchMatrix.app")}</BuildActionEntry></BuildActionEntries></BuildAction><TestAction buildConfiguration="Debug" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO">{reference(ut,"MatchMatrixUITests.xctest")}</TestableReference></Testables></TestAction><LaunchAction buildConfiguration="Debug" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{reference(target,"MatchMatrix.app")}</BuildableProductRunnable></LaunchAction></Scheme>''')
asset=add(uid(600),'isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>";')
assetbuild=add(uid(601),f'isa = PBXBuildFile; fileRef = {asset};')
objects[main]=objects[main].replace('children = (',f'children = ({asset},')
objects[resources]=objects[resources].replace('files = ()',f'files = ({assetbuild})')
for n in [300,301]: objects[uid(n)]=objects[uid(n)].replace('buildSettings = {','buildSettings = {ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon; ')
(root/'MatchMatrix.xcodeproj/project.pbxproj').write_text('// !$*UTF8*$!\n{ archiveVersion = 1; classes = {}; objectVersion = 56; objects = {\n'+ '\n'.join(f'{key} = {{{body}}};' for key,body in objects.items())+f'\n}}; rootObject = {project}; }}')

pbx=root/"MatchMatrix.xcodeproj/project.pbxproj"
pbx.write_text(pbx.read_text().replace("; ", ";\n").replace("{", "{\n"))

# Keep WidgetKit, App Groups, and widget tests when regenerating the legacy project.
import runpy
runpy.run_path(str(root / "configure_widgets.py"))
