import "whatwg-fetch"

export default class MarkdownEditor {
  constructor(textarea, options = {}) {
    this.textarea = textarea;
    this.endPoint = options['endPoint'] ? options['endPoint'] : '/api/image.json';
    this.paramName = options['paramName'] ? options['paramName'] : 'file';
    textarea.addEventListener("drop", (e) => this.drop(e));
    textarea.addEventListener("paste", (e) => this.paste(e));
  }

  drop(event) {
    event.preventDefault();
    this.uploadAll(event.dataTransfer.files);
  }

  paste(event) {
    event.preventDefault();
    this.uploadAll(event.clipboardData.files);
  }

  csrfToken() {
    let meta = document.querySelector("meta[name=\"csrf-token\"]");
    if (meta) { return meta.content; }
  }

  uploadAll(files) {
    for (let i = 0; i < files.length; i++) {
      this.upload(files[i]);
    }
  }

  upload(file) {
    const reader = new FileReader();
    reader.readAsText(file);
    reader.onload = (event) => {
      const text = `![${file.name}をアップロード中...]()`;

      const beforeRange = this.textarea.selectionStart;
      const afterRange = text.length;
      const beforeText = this.textarea.value.substring(0, beforeRange);
      const afterText = this.textarea.value.substring(beforeRange, this.textarea.value.length);
      this.textarea.value = `${beforeText}\n${text}\n${afterText}`;

      let params = new FormData();
      params.append(this.paramName, file);

      fetch(this.endPoint, {
        method: 'POST',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.csrfToken()
        },
        credentials: 'same-origin',
        body: params
      }).then((response) => {
        return response.json();
      }).then((json) => {
        this.textarea.value = this.textarea.value.replace(`![${file.name}をアップロード中...]()`, `![${file.name}](${json['url']})\n`);
      }).catch((ex) => {
        console.warn('parsing failed', ex)
      })
    };
  }
}
