"""Restore the widget targets and tests after the legacy app project generator runs."""
from pathlib import Path
import json, subprocess, shutil
root=Path(__file__).parent
p=root/'MatchMatrix.xcodeproj/project.pbxproj'
doc=json.loads(subprocess.check_output(['plutil','-convert','json','-o','-',str(p)]))
patch=json.loads((root/'Support/widget-project.json').read_text())
def merge(old,new):
    if isinstance(new,dict):
        for k,v in new.items(): old[k]=merge(old[k],v) if k in old else v
        return old
    if isinstance(new,list): return old+[v for v in new if v not in old]
    return new
import runpy
formatter = runpy.run_path(str(root / 'Support/project_format.py'))
p.write_text(formatter['serialize'](formatter['prepare'](merge(doc,patch))))
shutil.copy2(root/'Support/widget-scheme.xcscheme',root/'MatchMatrix.xcodeproj/xcshareddata/xcschemes/MatchMatrix.xcscheme')
