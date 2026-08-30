# Credits

Two of the skills shipped in this repository are **adaptations of existing open-source
projects**, not original work. Both upstreams are MIT-licensed. Their copyright notices are
reproduced below as the licence requires.

If you want the full-featured versions, install them from the upstreams — they are actively
maintained and do more than the condensed copies here.

---

## `skills/claudeception/`

Adapted from **Claudeception** by blader — https://github.com/blader/Claudeception

The version in this repo is a condensed single-file rewrite (~90 lines vs the upstream's ~400)
that drops the examples, resources and helper scripts to fit the minimal-core philosophy of this
template. The concept, the name and the trigger design are the upstream project's.

```
MIT License

Copyright (c) 2024 Claude Code

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## `skills/claude-reflect/`

Adapted from **claude-reflect** by Bayram Annakov — https://github.com/BayramAnnakov/claude-reflect

The version in this repo keeps the two-stage capture → review design and the
`capture_learning.py` helper, but ships without the upstream's plugin packaging, hooks bundle
and command set. The concept, the name and the two-stage architecture are the upstream
project's.

```
MIT License

Copyright (c) 2025 Bayram Annakov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

Everything else in this repository — the memory model, the session lifecycle, the hooks, the
remaining skills and the template — is original work under the MIT licence in `LICENSE`.
