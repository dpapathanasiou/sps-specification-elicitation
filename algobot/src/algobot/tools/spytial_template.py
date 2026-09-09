HEAD = """<script src="https://cdn.jsdelivr.net/npm/spytial-core/dist/browser/spytial-core-complete.global.js"></script>"""

CSS_TEMPLATE = """
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
"""

HTML_TEMPLATE = """<webcola-cnd-graph id="g"></webcola-cnd-graph>"""

JS_OPENING = """
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

JS_CLOSING = """`;

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

            // 4.  Render the layout
            const graph = document.getElementById('g');
            graph.renderLayout(layout);

            // add a full-screen toggle button
            const button = document.createElement('button');
            button.textContent = '⛶';
            button.title = 'Full screen';
            button.onclick = () => {
              if (document.fullscreenElement === graph) document.exitFullscreen();
              else graph.requestFullscreen();
            };

            // The box just changed size, so fit the diagram to it again.
            document.addEventListener('fullscreenchange', () => {
              requestAnimationFrame(() => graph.resetViewToFitContent());
            });
            graph.addToolbarControl(button);
"""
