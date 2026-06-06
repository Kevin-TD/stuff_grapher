let board = JXG.JSXGraph.initBoard(
    'box', {
        boundingbox: [-10, 10, 10, -10],
        axis: true
    })

// point
var A = board.create('point', [2, 1], {name: 'A'});

let f = (x) => 0.5 * x ** 2 - 2 *x

// function
var f1 = board.create(
    'functiongraph',
    [(x) => 0.5 * x ** 2 - 2 * x],
    {strokeWidth: 3}
);

// derivative
var d = board.create('derivative', [f1]);

// integral
var i1 = board.create(
    "functiongraph",
    [(x) => JXG.Math.Numerics.I([-1, x], f)]
)

// docs: https://jsxgraph.org/docs/
// manual: https://ipesek.github.io/jsxgraphbook/ 