const MQ = MathQuill.getInterface(2)
const list = document.getElementById('block-list')
const addBtn = document.getElementById('add-btn')
let blocks = []
let lastKey = null
let lastTwoKeys = ""

// note: "int" command called with capital I so "Int".
// this is due to existing collision with "in" keyword

// only the ones that i care about
let greekConstants = "alpha beta gamma delta zeta theta kappa lambda xi pi rho sigma tau phi chi psi omega Gamma Delta Theta Lambda Xi Sigma Phi Psi Omega"
let autoCommandNames = "sqrt sum prod int"

let allAutoCommands = `${greekConstants} ${autoCommandNames}`

let namesToEmbolden = SGL.namesToEmbolden()

let newNamesAdded = []

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

    if (e.key === 't' && lastTwoKeys === 'In') {
      e.preventDefault();
      mqField.keystroke('Backspace');
      mqField.keystroke('Backspace');
      mqField.cmd('\\int');
    }

    if (!["Shift", "Control", "Alt", "Meta"].includes(e.key)) {
      lastTwoKeys = (lastTwoKeys + e.key).slice(-2);
      lastKey = e.key;
    }

  });

  mqSpan.addEventListener('keyup', (e) => {
    console.log(getCode())

    try {
      let code = getCode()
      let output = SGL.parseStringInput(code)
      let newVarNames = SGL.getNewVarNames(code)
      
      let newNamesToAdd = newVarNames.filter(x => 
        x.length > 1 && 
        !namesToEmbolden.split(" ").includes(x) &&
        !allAutoCommands.split(" ").includes(x) &&
        !greekConstants.split(" ").includes(x.split("_")[0]) &&
        !newNamesAdded.includes(x)
      )

      console.log(newNamesToAdd)
      console.log(output)

      for (let newVar of newNamesToAdd) {
        if (!newNamesAdded.includes(newVar)) {
          newNamesAdded.push(newVar)
        }
      }

      let allNewNames = SGL.namesToEmbolden() + " " + newNamesAdded.join(" ")

      if (newNamesToAdd.length > 0 && allNewNames != namesToEmbolden) {
        for (let block of blocks) {
          block.config({ autoOperatorNames: allNewNames })
          block.latex(block.latex()) // re-renders the block
        }
        namesToEmbolden = allNewNames
      }

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
          .replace(/\\text{[^}]*}|\\[a-zA-Z]+|([a-zA-Z][a-zA-Z0-9_]+)/g, (match, ident) => {
          if (ident) return `\\text{${ident}}`;
              return match;
          })
        
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