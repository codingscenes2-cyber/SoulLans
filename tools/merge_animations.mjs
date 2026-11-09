import { NodeIO } from '@gltf-transform/core';
import { KHRONOS_EXTENSIONS } from '@gltf-transform/extensions';
import fs from 'node:fs/promises';

const [characterPath, outputPath, ...animationPaths] = process.argv.slice(2);
if (!characterPath || !outputPath || animationPaths.length === 0) {
  console.error('Usage: node merge_animations.mjs <character.glb> <output.glb> <animation-library-1.glb> [animation-library-2.glb ...]');
  process.exit(2);
}

const io = new NodeIO().registerExtensions(KHRONOS_EXTENSIONS);
const character = await io.read(characterPath);
const characterRoot = character.getRoot();

const characterNodes = new Map();
for (const node of characterRoot.listNodes()) {
  if (node.getName()) characterNodes.set(node.getName(), node);
}

const mappedNodes = new Map();
const unmatched = [];
const animationRoots = [];
for (const animationPath of animationPaths) {
  const animationLibrary = await io.read(animationPath);
  animationRoots.push({ path: animationPath, root: animationLibrary.getRoot() });
  for (const node of animationLibrary.getRoot().listNodes()) {
    const name = node.getName();
    if (!name) continue;
    const destination = characterNodes.get(name);
    if (destination) mappedNodes.set(node, destination);
    else unmatched.push(name);
  }
}

const copyAccessor = (source) => {
  const array = source.getArray();
  const accessor = character.createAccessor()
    .setType(source.getType())
    .setNormalized(source.getNormalized());
  if (array) accessor.setArray(array.slice());
  return accessor;
};

let copiedClips = 0;
let copiedChannels = 0;
let sourceChannels = 0;
let unmappedTargets = new Set();
const perClip = [];
for (const { path: sourcePath, root: animationRoot } of animationRoots) {
for (const animation of animationRoot.listAnimations()) {
  const name = animation.getName();
  if (!name) throw new Error('Animation library contains an unnamed clip.');
  if (characterRoot.listAnimations().some(existing => existing.getName() === name)) {
    console.log(`Skipping duplicate clip ${name} from ${sourcePath}`);
    continue;
  }
  const destinationAnimation = character.createAnimation(name);
  let clipCopied = 0;
  for (const channel of animation.listChannels()) {
    sourceChannels++;
    const sourceTarget = channel.getTargetNode();
    const target = mappedNodes.get(sourceTarget);
    if (!target && sourceTarget?.getName()) unmappedTargets.add(sourceTarget.getName());
    const sampler = channel.getSampler();
    if (!target || !sampler?.getInput() || !sampler?.getOutput()) continue;
    const destinationSampler = character.createAnimationSampler()
      .setInput(copyAccessor(sampler.getInput()))
      .setOutput(copyAccessor(sampler.getOutput()))
      .setInterpolation(sampler.getInterpolation());
    destinationAnimation.addSampler(destinationSampler).addChannel(
      character.createAnimationChannel()
        .setTargetNode(target)
        .setTargetPath(channel.getTargetPath())
        .setSampler(destinationSampler)
    );
    copiedChannels++;
    clipCopied++;
  }
  perClip.push({ name, source: animation.listChannels().length, copied: clipCopied });
  if (clipCopied > 0) copiedClips++;
}
}

const required = ['Idle_Loop', 'Walk_Loop', 'Jog_Fwd_Loop', 'Sprint_Loop', 'Jump_Start', 'Jump_Loop', 'Jump_Land', 'Roll', 'Sword_Attack', 'Sword_Idle', 'Death01', 'Hit_Chest'];
const names = new Set(characterRoot.listAnimations().map(animation => animation.getName()));
const missing = required.filter(name => !names.has(name));
console.log(JSON.stringify({ mappedNodes: mappedNodes.size, sourceChannels, copiedChannels, unmappedTargetNames: [...unmappedTargets].slice(0, 30), perClip: perClip.slice(0, 12), animationNames: [...names] }, null, 2));
if (missing.length) throw new Error(`Required combat/locomotion clips missing: ${missing.join(', ')}`);
if (mappedNodes.size < 60) throw new Error(`Only ${mappedNodes.size} skeleton nodes matched; expected at least 60.`);

const bytes = await io.writeBinary(character);
await fs.writeFile(outputPath, bytes);
console.log(JSON.stringify({
  mappedNodes: mappedNodes.size,
  unmatchedNodeNames: [...new Set(unmatched)],
  copiedClips,
  copiedChannels,
  animationLibraries: animationRoots.map(entry => entry.path),
  outputBytes: bytes.byteLength,
  requiredClips: required
}, null, 2));
