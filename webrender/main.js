const MQ = MathQuill.getInterface(2)
const list = document.getElementById('block-list')
const addBtn = document.getElementById('add-btn')
let blocks = []
let lastKey = null

// only the ones that i care about. which is what most matheticians only care about
let greekConstants = "alpha beta gamma delta zeta theta kappa lambda mu xi pi rho sigma tau phi chi psi omega Gamma Delta Theta Lambda Xi Sigma Phi Psi Omega"
let autoCommandNames = "sqrt sum prod int"

let allAutoCommands = `${greekConstants} ${autoCommandNames}`

let namesToEmbolden = SGL.namesToEmbolden()

// removes the the preceeding "\" when greek constants are typed into the latex. made so SGL can parse it
function removeLatexArtifacts(str) {
  let s = str
  let allConsts = `${greekConstants} ${namesToEmbolden}`
  allConsts = allConsts.split(" ")
  for (let c of allConsts) {
    s = s.replaceAll(`\\${c}`, c)
  }
  return s
}

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
    autoOperatorNames: namesToEmbolden,
    autoCommands: allAutoCommands,
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

  mqField.resultEl = resultEl
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

  mqSpan.addEventListener('input', (e) => {
    console.log(getCode())

    try {
      let output = SGL.parseStringInput(getCode())

      for (let i = 0; i < blocks.length; i++) {
        let outputResult = output[i + 1]

        if (outputResult !== undefined) {
          if (outputResult === "") {
            blocks[i].resultEl.textContent = ""
          } else {
            blocks[i].resultEl.textContent = `= ${outputResult}`
          }
        }
      }
    } 
    catch { 
      
    }
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
        // operatorname to text hack: if i leave it as operatorname, the mathlive parser will not interpret our custom functions like "if" as a function but as two symbols "i" and "f" so it turns into "i f". in order to prevent this, i wrap it in a text block; this parses text{if} into "if" (including the quotes), keeping the letters together. all that is then left is to remove the quotes with normal regex

        let parseableEq = rawLatex
            .replace(/\\operatorname{(.*?)}/g, "\\text{$1}")
            .replace(/\\ne/g, "!=")
            .replace(/\\leftarrow/g, "<-")
            .replace(/\\rightarrow/g, "->")

        parseableEq = 
          MathLive.convertLatexToAsciiMath(parseableEq)
          .replace(/"(.*?)"/g, " $1 ")
          
        codes.push(parseableEq)
    }
    return codes.join("\n")
}

let board = JXG.JSXGraph.initBoard(
    'box', {
        boundingbox: [-10, 10, 10, -10],
        axis: true
    })