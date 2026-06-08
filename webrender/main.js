const list = document.getElementById('block-list')
const addBtn = document.getElementById('add-btn')
let blocks = []
let lastKey = null

// only the ones that i care about. which is what most matheticians only care about
let greekConstants = "alpha beta gamma delta zeta theta kappa lambda mu xi pi rho sigma tau phi chi psi omega Gamma Delta Theta Lambda Xi Sigma Phi Psi Omega"
let autoCommandNames = "sqrt sum prod int"

let allInlineShortcuts = SGL.namesToEmbolden()

allInlineShortcuts = allInlineShortcuts.split(" ")
greekConstants = greekConstants.split(" ")
autoCommandNames = autoCommandNames.split(" ")

let customMacros = {}
let customInlineShortcuts = {
   "*": "\\cdot"
}

for (let greekConst of greekConstants) {
  customInlineShortcuts[greekConst] = `\\${greekConst}`
}

for (let autoCmd of autoCommandNames) {
  customInlineShortcuts[autoCmd] = `\\${autoCmd}`
}

for (let shortcut of allInlineShortcuts) {
  customMacros[shortcut] = `\\operatorname{${shortcut}}`
  customInlineShortcuts[shortcut] = `\\${shortcut}`
}

const asciiFixRegex = (() => {
  const names = allInlineShortcuts.sort((a, b) => b.length - a.length);
  const patterns = names.map(name => name.split('').join('\\s*'));
  return new RegExp(`\\b(${patterns.join('|')})\\b`, 'g');
})();

function fixAsciiMath(str) {
  return str.replace(asciiFixRegex, match => match.replace(/\s+/g, ''));
}

function createBlock(index, focusIt = true) {
  const blockEl = document.createElement('div');
  blockEl.className = 'math-block';

  const numEl = document.createElement('div');
  numEl.className = 'block-num';

  const mqWrap = document.createElement('div');
  mqWrap.className = 'mq-wrap';

  const resultEl = document.createElement('div');
  resultEl.className = 'block-result';
  resultEl.textContent = '= 0';

  const mf = document.createElement('math-field');
  mf.style.width = '100%';

  // tell mathlive which operator names to recognize (your SGL functions)

  mf.addEventListener('mount', () => {
    mf.macros = customMacros
    mf.inlineShortcuts = customInlineShortcuts
    mf.mathModeSpace = '\\:';
  });

  mqWrap.appendChild(mf);
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

  mf.resultEl = resultEl;
  blocks[index] = mf;

  mf.addEventListener('keydown', (e) => {
    const i = getIndex(blockEl);

    if (e.key === 'Enter') {
      e.preventDefault();
      createBlock(i + 1, true);
    }
    if (e.key === 'Backspace' && mf.getValue('latex') === '' && blocks.length > 1) {
      e.preventDefault();
      blockEl.remove();
      blocks.splice(i, 1);
      updateNumbers();
      focusBlock(Math.min(i, blocks.length - 1));
    }
    if (e.key === 'ArrowUp') { e.preventDefault(); focusBlock(i - 1); }
    if (e.key === 'ArrowDown') { e.preventDefault(); focusBlock(i + 1); }
  });

  mf.addEventListener('input', () => {
    console.log(getCode())
    try {
      let output = SGL.parseStringInput(getCode());
      for (let i = 0; i < blocks.length; i++) {
        let outputResult = output[i + 1];
        if (outputResult !== undefined) {
          blocks[i].resultEl.textContent = outputResult === "" ? "" : `= ${outputResult}`;
        }
      }
    } catch {}
  });

  updateNumbers();
  if (focusIt) setTimeout(() => mf.focus(), 0);

  return mf;
}

function getIndex(blockEl) {
  return Array.from(list.children).indexOf(blockEl);
}

function focusBlock(i) {
  if (i >= 0 && i < blocks.length) {
    blocks[i].focus()
  }
}

function updateNumbers() {
  Array.from(list.children).forEach((el, i) => {
    el.querySelector('.block-num').textContent = i + 1;
  });
}

function getCode() {
  return blocks.map(mf => fixAsciiMath(mf.getValue('ascii-math'))).join('\n');
}

addBtn.addEventListener('click', () => createBlock(blocks.length, true));
createBlock(0, true);

let board = JXG.JSXGraph.initBoard('box', {
  boundingbox: [-10, 10, 10, -10],
  axis: true
});