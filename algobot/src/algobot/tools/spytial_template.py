OPENING = """
<!doctype html>
<html>
    <head>
        <meta charset="utf-8" />
        <title>Spytial Spec Visualizer</title>
        <script src="https://cdn.jsdelivr.net/npm/spytial-core/dist/browser/spytial-core-complete.global.js"></script>
        <style>
            html,
            body {
                height: 100%; /* let the body fill the viewport */
                margin: 0; /* no default margin */
            }
            #g {
                display: block; /* block so width/height work */
                /* let the graph grow with its parent: */
                width: 99%;
                height: 100%;
            }
        </style>
    </head>

    <body>
        <webcola-cnd-graph id="g"></webcola-cnd-graph>

        <script>
            /**
             * Create a spytial-core AlloyDataInstance from an Alloy XML string.
             *
             * @param {string} xmlString  The full <alloy>...</alloy> document.
             * @returns {AlloyDataInstance}
             */
            function loadAlloyDataInstanceFromXml(xmlString) {
                const parser = new DOMParser();
                const doc = parser.parseFromString(xmlString, "text/xml");

                const instance = spytialcore.createEmptyAlloyDataInstance();

                // 1.  Map every <sig> to a type name (label -> id)
                const idToType = new Map();
                const sigs = doc.querySelectorAll("sig");
                sigs.forEach((sig) => {
                    const typeId = sig.getAttribute("ID");
                    const typeName = sig.getAttribute("label");

                    // Skip builtin types that we don't want to expose as nodes
                    if (sig.getAttribute("builtin") === "yes") return;

                    idToType.set(typeId, typeName);
                });

                // 2.  Add every atom
                sigs.forEach((sig) => {
                    const typeName = idToType.get(sig.getAttribute("ID"));
                    if (!typeName) return; // builtin types were skipped

                    const atoms = sig.querySelectorAll("atom");
                    atoms.forEach((atomEl) => {
                        const atomId = atomEl.getAttribute("label");
                        instance.addAtom({ id: atomId, type: typeName });
                    });
                });

                // 3.  Add every relation tuple
                const fields = doc.querySelectorAll("field");
                fields.forEach((field) => {
                    const relName = field.getAttribute("label");

                    // We could infer the relation's type from the <types> child,
                    // but `addRelationTuple` will create the relation automatically
                    // if it does not yet exist, so we can skip this step

                    const tuples = field.querySelectorAll("tuple");
                    tuples.forEach((tuple) => {
                        const atomEls = tuple.querySelectorAll("atom");
                        const atomIds = Array.from(atomEls).map((a) =>
                            a.getAttribute("label"),
                        );

                        instance.addRelationTuple(relName, { atoms: atomIds });
                    });
                });

                return instance;
            }

            // XML content, output of the Alloy evaluation, embedded as a string
            const alloyXml = `<?xml version="1.0" encoding="UTF-8"?>
"""

CLOSING = """`;

            const { parseLayoutSpec, SGraphQueryEvaluator, LayoutInstance } =
                spytialcore;

            const spec = `
      constraints:
        - orientation: { selector: addresses, directions: [above] }
      directives:
        - atomStyle: { selector: this/EmailAddress, borderStyle: { color: "#4a90d9" } }
        - flag: hideDisconnectedBuiltIns
    `;

            const instance = loadAlloyDataInstanceFromXml(alloyXml);
            const layoutSpec = parseLayoutSpec(spec);
            const evaluator = new SGraphQueryEvaluator();
            evaluator.initialize({ sourceData: instance });

            const generatedLayout = new LayoutInstance(
                layoutSpec,
                evaluator,
            ).generateLayout(instance);
            const layout = generatedLayout.layout;

            /* --------------------------------------------------------------------
       4.  Render the layout
       -------------------------------------------------------------------- */
            document.getElementById("g").renderLayout(layout);
        </script>
    </body>
</html>
"""
