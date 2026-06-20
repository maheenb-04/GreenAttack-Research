import textwrap

import nbformat
from nbclient import NotebookClient

SOURCE_NOTEBOOK = "Demo.ipynb"
OUTPUT_NOTEBOOK = "Demo.executed.ipynb"

nb = nbformat.read(SOURCE_NOTEBOOK, as_version=4)

client = NotebookClient(
    nb,
    timeout=60,
    iopub_timeout=300,
    kernel_name="python3",
)


def run_cell(client, source, label):
    print(f"\n--- Running {label} ---", flush=True)
    print(source[:1000], flush=True)

    cell = nbformat.v4.new_code_cell(source)
    client.execute_cell(cell, 0)

    for output in cell.get("outputs", []):
        output_type = output.get("output_type")
        if output_type == "stream":
            print(output.get("text", ""), end="", flush=True)
        elif output_type == "error":
            print("ERROR:", output.get("ename"), output.get("evalue"), flush=True)
            print("\n".join(output.get("traceback", [])), flush=True)
        elif output_type in {"execute_result", "display_data"}:
            data = output.get("data", {})
            if "text/plain" in data:
                print(data["text/plain"], flush=True)

    print(f"--- Finished {label} ---", flush=True)


cell_2 = nb.cells[2]

if cell_2.cell_type != "code":
    raise RuntimeError("Expected Demo.ipynb cell 2 to be a code cell")

cell_2_lines = []
for line in cell_2.source.splitlines():
    stripped = line.strip()
    if not stripped:
        continue
    if stripped.startswith("#"):
        continue
    cell_2_lines.append(line)

with client.setup_kernel():
    run_cell(
        client,
        textwrap.dedent(
            """
            import faulthandler, sys
            faulthandler.enable()
            print("debug kernel ready", flush=True)
            """
        ),
        "debug setup",
    )

    print("\n=== Breaking Demo.ipynb cell 2 into one-line executions ===", flush=True)

    for index, line in enumerate(cell_2_lines, start=1):
        run_cell(client, line, f"cell 2 line {index}")

    print("\n=== Cell 2 line-by-line execution completed ===", flush=True)

nbformat.write(nb, OUTPUT_NOTEBOOK)
print(f"Wrote {OUTPUT_NOTEBOOK}", flush=True)