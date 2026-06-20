import nbformat
from nbclient import NotebookClient

nb = nbformat.read("Demo.ipynb", as_version=4)
client = NotebookClient(
    nb,
    timeout=-1,
    iopub_timeout=300,
    kernel_name="python3",
)

with client.setup_kernel():
    for i, cell in enumerate(nb.cells):
        if cell.cell_type != "code":
            continue

        print(f"\n--- Running cell {i} ---", flush=True)
        print(cell.source[:500], flush=True)

        client.execute_cell(cell, i)

        print(f"--- Finished cell {i} ---", flush=True)

nbformat.write(nb, "Demo.executed.ipynb")
print("Wrote Demo.executed.ipynb", flush=True)
