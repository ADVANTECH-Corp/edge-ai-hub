import importlib
import sys


mods = [
    "torch",
    "transformers",
    "nanoowl",
]

optional_mods = [
    "tensorrt",
    "torch2trt",
]

print("[smoke] Python:", sys.version)

for m in mods:
    importlib.import_module(m)
    print(f"[smoke] ok: {m}")

for m in optional_mods:
    try:
        importlib.import_module(m)
        print(f"[smoke] ok(optional): {m}")
    except Exception as e:
        print(f"[smoke] warn(optional): {m}: {e}")

print("[smoke] import test complete")
