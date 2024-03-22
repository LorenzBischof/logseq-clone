# Logseq Cloner

Logseq on Android can be slow to start. If you have multiple graphs, you often need to wait for Logseq to load, ensure you are on the correct graph, and possibly switch to another graph.

Wouldn't it be convenient if you could start Logseq with a specific graph already selected?

Logseq Cloner allows you to repackage Logseq so that you can install it a second time. This second instance of Logseq can use a separate graph and be launched directly from the homescreen.

The build process utilizes Nix to ensure reproducible builds and transparency in the changes made. With Nix, users can trust and track the modifications made during the build process. Additionally, you have the option to run the build locally using `nix build`.
