const MQ = MathQuill.getInterface(2)
const list = document.getElementById('block-list')
const addBtn = document.getElementById('add-btn')
let blocks = []
let lastKey = null

function createBlock(index, focusIt = true) {
  const blockEl = document.createElement('div');
  blockEl.className = 'math-block';

  const numEl = document.createElement('div');
  numEl.className = 'block-num';

  const mqWrap = document.createElement('div');
  mqWrap.className = 'mq-wrap';

  const mqSpan = document.createElement('span');
  mqWrap.appendChild(mqSpan);

  const resultEl = document.createElement('div');
  resultEl.className = 'block-result';
  resultEl.textContent = '= 0';

  mqWrap.appendChild(resultEl);
  blockEl.appendChild(numEl);
  blockEl.appendChild(mqWrap);

  if (index >= blocks.length) {
    list.appendChild(blockEl);
    blocks.push(null);
  } else {
    list.insertBefore(blockEl, list.children[index]);
    blocks.splice(index, 0, null);
  }

  const mqField = MQ.MathField(mqSpan, {
    autoOperatorNames: "if then else for when range fun",
    autoCommands: "pi theta sqrt sum int",
    autoSubscriptNumerals: true,
    sumStartsWithNEquals: true,
    spaceBehavesLikeTab: false,
    handlers: {
      enter() {
        createBlock(getIndex(blockEl) + 1, true);
      },
      upOutOf() {
        const i = getIndex(blockEl);
        if (i > 0) focusBlock(i - 1);
      },
      downOutOf() {
        const i = getIndex(blockEl);
        if (i < blocks.length - 1) focusBlock(i + 1);
      }
    }
  });

  blocks[index] = mqField;

  mqSpan.addEventListener('keydown', (e) => {
    if (e.key === 'Backspace' && mqField.latex() === '' && blocks.length > 1) {
      e.preventDefault();
      const i = getIndex(blockEl);
      blockEl.remove();
      blocks.splice(i, 1);
      updateNumbers();
      focusBlock(Math.min(i, blocks.length - 1));
    }
    if (e.key === 'ArrowUp') {
      const i = getIndex(blockEl);
      if (i > 0) { e.preventDefault(); focusBlock(i - 1); }
    }
    if (e.key === 'ArrowDown') {
      const i = getIndex(blockEl);
      if (i < blocks.length - 1) {
        e.preventDefault()
        focusBlock(i + 1)
      }
    }
    if (e.key === '=' && lastKey === '!') {
      e.preventDefault();
      mqField.keystroke('Backspace');
      mqField.write('\\ne');
    }
    if (e.key === "-" && lastKey === "<") {
      e.preventDefault();
      mqField.keystroke('Backspace');
      mqField.write('\\quad\\leftarrow\\quad');
    }
    if (e.key === ">" && lastKey === "-") {
      e.preventDefault();
      mqField.keystroke('Backspace');
      mqField.write('\\quad\\rightarrow\\quad');
    }

    if (!["Shift", "Control", "Alt", "Meta"].includes(e.key)) {
      lastKey = e.key;
    }

  });

  mqSpan.addEventListener('keyup', (e) => {
    console.log(getCode())
    let f = SGL.parseStringInput(getCode())
    console.log(f)
  })

  mqWrap.addEventListener('click', () => mqField.focus());

  updateNumbers();

  if (focusIt) {
    setTimeout(() => mqField.focus(), 0);
  }

  return mqField;
}

function getIndex(blockEl) {
  return Array.from(list.children).indexOf(blockEl);
}

function focusBlock(i) {
  if (i >= 0 && i < blocks.length) blocks[i].focus();
}

function updateNumbers() {
  Array.from(list.children).forEach((el, i) => {
    el.querySelector('.block-num').textContent = i + 1;
  });
}

addBtn.addEventListener('click', () => createBlock(blocks.length, true));
createBlock(0, true);

function getCode() {
    let codes = []
    for (let block of blocks) {
        let rawLatex = block.latex()
        let parseableEq = rawLatex
            .replace(/\\left\(/g, "(")
            .replace(/\\right\)/g, ")")
            .replace(/\\left\[/g, "[")
            .replace(/\\right\]/g, "]")
            .replace(/\\quad/g, " ")
            .replace(/\\operatorname{(.*?)}/g, " $1 ")
            .replace("\\cdot", "*")
            .replace("\\ne", "!=")
            .replace("\\leftarrow", "<-")
            .replace("\\rightarrow", "->")
            .replace(/\\(.*?){(.*?)}/g, "$1($2)")
            .replace(/\^{(.*?)}/g, "^($1)")

        codes.push(parseableEq)
    }
    return codes.join("\n")
}

let board = JXG.JSXGraph.initBoard(
    'box', {
        boundingbox: [-10, 10, 10, -10],
        axis: true
    })

let sampleCode = `a = 10
9 + 10
a + 10`

let sampleOutput = SGL.parseStringInput(sampleCode)

console.log(sampleOutput)