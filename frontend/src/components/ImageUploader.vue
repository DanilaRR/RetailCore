<template>
  <div class="image-uploader">
    <!-- Loading state -->
    <div v-if="isLoading" class="loading-state">
      <p>⏳ Loading image...</p>
    </div>

    <!-- Upload area always visible so user can pick another file anytime -->
    <div class="upload-area">
      <input
        :id="inputId"
        ref="fileInputEl"
        type="file"
        accept="image/jpeg,image/png"
        @change="handleFileSelect"
        @click="onInputClick"
        @focus="onInputFocus"
        @blur="onInputBlur"
        style="position: absolute; left: -9999px;"
      />
      <label :for="inputId" class="btn btn-primary" :aria-disabled="isLoading" @click="onLabelClick">
        📸 Upload Image
      </label>
      <p class="info-text">Click to select JPG or PNG (max 2MB)</p>
      <p class="hint-text">💡 Any image will be cropped to a square — you choose the area</p>
    </div>

    <!-- Show preview / cropper if image is selected -->
    <div v-if="isImageSelected" class="image-preview-container">
      <h3>✂️ Crop to Square</h3>
      <p class="crop-hint">Drag the selection to choose which area to use. The result will always be a square.</p>
      <div class="cropper-container">
        <Cropper
        v-if="imagePreview"
        ref="cropperRef"
        :src="imagePreview"
        :stencil-props="{ aspectRatio: 1 }"
      />
      </div>
      <div class="cropper-controls">
        <button class="btn btn-danger" type="button" @click="cancelCrop" :disabled="isProcessing">
          ❌ Cancel
        </button>
        <button class="btn btn-success" type="button" @click="cropImage" :disabled="isProcessing">
          {{ isProcessing ? '⏳ Processing...' : '✅ Apply & Save' }}
        </button>
      </div>
      <p class="info-text">Max size: 2MB | Formats: JPG, PNG</p>
    </div>

    <!-- Show cropped preview if completed -->
    <div v-if="croppedImageData && !isImageSelected" class="cropped-preview">
      <img :src="croppedImageData" alt="Cropped preview" class="preview-img" />
      <button class="btn btn-secondary" type="button" @click="resetImage">🔄 Change Image</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onBeforeUnmount } from 'vue';
import { Cropper } from 'vue-advanced-cropper';
import 'vue-advanced-cropper/dist/style.css';

const emit = defineEmits<{
  imageSelected: [imageData: string];
}>();

const fileInputEl = ref<HTMLInputElement | null>(null);
const cropperRef = ref<any | null>(null);
// unique id per component instance to avoid duplicate id collisions
const instanceSuffix = Math.random().toString(36).slice(2, 9);
const inputId = `file-input-${instanceSuffix}`;

// diagnostic helpers to log interactions that may cause freezes
const onLabelClick = (_e: Event) => {
  try {
    console.debug('[ImageUploader] label click', { time: performance.now(), id: inputId });
  } catch (err) {}
};

const onInputClick = (_e: Event) => {
  try {
    console.debug('[ImageUploader] input click', { time: performance.now(), id: inputId });
  } catch (err) {}
};

const onInputFocus = (_e: Event) => {
  try {
    console.debug('[ImageUploader] input focus', { time: performance.now(), id: inputId });
  } catch (err) {}
};

const onInputBlur = (_e: Event) => {
  try {
    console.debug('[ImageUploader] input blur', { time: performance.now(), id: inputId });
  } catch (err) {}
};
const imageData = ref<string>(''); // original filename (optional)
const imagePreview = ref<string>(''); // data URL
const croppedImageData = ref<string>('');
const isLoading = ref(false);
const isProcessing = ref(false);
const isImageSelected = ref(false);

// use label[for] to open file dialog; no programmatic click to avoid browser-specific hangs

const handleFileSelect = async (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (!file) return;

  // Validate file size (2MB)
  const maxSizeBytes = 2 * 1024 * 1024;
  if (file.size > maxSizeBytes) {
    alert('❌ File size exceeds 2MB limit');
    // Reset file input
    target.value = '';
    return;
  }

  // Validate file format
  if (!['image/jpeg', 'image/png'].includes(file.type)) {
    alert('❌ Only JPG and PNG formats are supported');
    // Reset file input
    target.value = '';
    return;
  }

  isLoading.value = true;

  try {
    const reader = new FileReader();
    reader.onload = async (e) => {
      try {
        imagePreview.value = e.target?.result as string;
        imageData.value = file.name;
        isImageSelected.value = true;
        // new cropper will mount via template and use imagePreview as src
      } catch (error) {
        console.error('Error processing image preview:', error);
        alert('Error processing image. Please try again.');
        cancelCrop();
      } finally {
        isLoading.value = false;
      }
    };
    reader.onerror = () => {
      console.error('FileReader error');
      alert('Error reading file. Please try again.');
      isLoading.value = false;
      target.value = '';
    };
    reader.readAsDataURL(file);
  } catch (error) {
    console.error('Error in handleFileSelect:', error);
    alert('Error selecting file. Please try again.');
    isLoading.value = false;
    target.value = '';
  }
};

// No imperative initialization required for vue3-cropper; the component will mount with imagePreview

// no native image load handling needed for vue-advanced-cropper

const cropImage = async () => {
  // Attempt to use vue3-cropper API if available, otherwise fallback to center-square crop
  isProcessing.value = true;
  try {
    let blob: Blob | null = null;

        // try to use vue-advanced-cropper API if present
        const cropperComp = cropperRef.value;
        if (cropperComp && typeof cropperComp.getResult === 'function') {
          try {
            const result = cropperComp.getResult();
            // result may contain a canvas
            if (result && result.canvas instanceof HTMLCanvasElement) {
              const canvas = result.canvas as HTMLCanvasElement;
              blob = await new Promise<Blob | null>((resolve) => canvas.toBlob((b) => resolve(b), 'image/png'));
            }
          } catch (e) {
            console.warn('vue-advanced-cropper getResult failed, will fallback', e);
          }
        }

    // Fallback: center-square crop using imagePreview
    if (!blob) {
      try {
        const img = new Image();
        img.crossOrigin = 'anonymous';
        img.src = imagePreview.value;
        await new Promise((res, rej) => {
          img.onload = res;
          img.onerror = rej;
        });
        const size = Math.min(img.naturalWidth, img.naturalHeight, 800);
        const sx = Math.floor((img.naturalWidth - size) / 2);
        const sy = Math.floor((img.naturalHeight - size) / 2);
        const off = document.createElement('canvas');
        off.width = 800;
        off.height = 800;
        const ctx = off.getContext('2d');
        if (!ctx) throw new Error('Canvas context unavailable');
        ctx.fillStyle = '#fff';
        ctx.fillRect(0, 0, 800, 800);
        ctx.drawImage(img, sx, sy, size, size, 0, 0, 800, 800);

        // convert to blob asynchronously
        blob = await new Promise<Blob | null>((resolve) => {
          off.toBlob((b) => resolve(b), 'image/png');
        });
      } catch (e) {
        console.error('Fallback crop failed', e);
        alert('Error cropping image. Please try again.');
        isProcessing.value = false;
        return;
      }
    }

    if (!blob) {
      alert('Error creating image blob. Please try again.');
      isProcessing.value = false;
      return;
    }

    // Read blob as base64 asynchronously
    const reader = new FileReader();
    const base64 = await new Promise<string | null>((resolve, reject) => {
      reader.onloadend = () => resolve(reader.result as string | null);
      reader.onerror = (e) => reject(e);
      reader.readAsDataURL(blob as Blob);
    });

    if (base64) {
      croppedImageData.value = base64;
      isImageSelected.value = false; // hide cropper, show preview
      emit('imageSelected', croppedImageData.value);
    } else {
      alert('Failed to read cropped image.');
    }
  } catch (error) {
    console.error('Error cropping image:', error);
    alert('Error cropping image. Please try again.');
  } finally {
    isProcessing.value = false;
  }
};

const cancelCrop = () => {
  imageData.value = '';
  imagePreview.value = '';
  croppedImageData.value = '';
  isImageSelected.value = false;
  if (cropperRef.value && typeof cropperRef.value.destroy === 'function') {
    try { cropperRef.value.destroy(); } catch (e) { /* ignore */ }
  }
  cropperRef.value = null;
  // Reset file input
  if (fileInputEl.value) {
    fileInputEl.value.value = '';
  }
};

const resetImage = () => {
  imageData.value = '';
  imagePreview.value = '';
  croppedImageData.value = '';
  isImageSelected.value = false;
  if (cropperRef.value && typeof cropperRef.value.destroy === 'function') {
    try { cropperRef.value.destroy(); } catch (e) { /* ignore */ }
  }
  cropperRef.value = null;
  // Reset file input
  if (fileInputEl.value) {
    fileInputEl.value.value = '';
  }
};

// Cleanup on unmount
onBeforeUnmount(() => {
  if (cropperRef.value && typeof cropperRef.value.destroy === 'function') {
    try { cropperRef.value.destroy(); } catch (e) { /* ignore */ }
  }
});

// Expose reset so parent components can clear the uploader (e.g. on modal close)
defineExpose({ reset: resetImage });
</script>

<style scoped>
.image-uploader {
  padding: 20px;
  border: 2px dashed #ccc;
  border-radius: 8px;
  background: #f9f9f9;
  text-align: center;
}

.loading-state {
  padding: 40px 20px;
  font-size: 16px;
  color: #666;
}

.upload-area {
  padding: 40px 20px;
}

.upload-area button {
  font-size: 16px;
  padding: 12px 24px;
  cursor: pointer;
}

.upload-area button:disabled,
.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.info-text {
  margin-top: 10px;
  font-size: 12px;
  color: #666;
}

.hint-text {
  margin-top: 6px;
  font-size: 12px;
  color: #2563eb;
  background: #eff6ff;
  border: 1px solid #bfdbfe;
  border-radius: 6px;
  padding: 6px 10px;
  display: inline-block;
}

.crop-hint {
  font-size: 13px;
  color: #555;
  margin: 0 0 12px;
}

.image-preview-container {
  width: 100%;
}

.image-preview-container h3 {
  margin-bottom: 15px;
  color: #333;
}

.cropper-container {
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 20px 0;
  max-height: 400px;
  overflow: auto;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: #f0f0f0;
}

.cropper-container img {
  max-width: 100%;
  max-height: 400px;
  display: block;
}

.cropper-controls {
  display: flex;
  gap: 10px;
  justify-content: center;
  margin: 20px 0;
}

.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: bold;
  transition: all 0.3s;
}

.btn-primary {
  background: #007bff;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #0056b3;
}

.btn-success {
  background: #28a745;
  color: white;
}

.btn-success:hover:not(:disabled) {
  background: #218838;
}

.btn-danger {
  background: #dc3545;
  color: white;
}

.btn-danger:hover:not(:disabled) {
  background: #c82333;
}

.btn-secondary {
  background: #6c757d;
  color: white;
}

.btn-secondary:hover:not(:disabled) {
  background: #5a6268;
}

.cropped-preview {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #ddd;
}

.preview-img {
  max-width: 200px;
  max-height: 200px;
  border-radius: 8px;
  margin-bottom: 15px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
</style>

