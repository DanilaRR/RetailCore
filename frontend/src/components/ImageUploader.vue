<template>
  <div class="image-uploader">
    <!-- Processing state -->
    <div v-if="isLoading || isProcessing" class="loading-state">
      <p>{{ isLoading ? '⏳ Loading image...' : '⏳ Processing image...' }}</p>
    </div>

    <!-- Upload area always visible so user can pick another file anytime -->
    <div class="upload-area">
      <input
        :id="inputId"
        ref="fileInputEl"
        type="file"
        accept="image/jpeg,image/png"
        @change="handleFileSelect"
        @click="resetFileInputBeforeSelect"
        style="position: absolute; left: -9999px;"
      />
      <label :for="inputId" class="btn btn-primary" :aria-disabled="isLoading || isProcessing">
        📸 Upload Image
      </label>
      <p class="info-text">Click to select JPG or PNG</p>
      <p class="hint-text">💡 Rectangular images are auto-cropped to a centered square; square images stay unchanged</p>
    </div>

  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const emit = defineEmits<{
  imageSelected: [imageData: string];
}>();

const fileInputEl = ref<HTMLInputElement | null>(null);
// unique id per component instance to avoid duplicate id collisions
const instanceSuffix = Math.random().toString(36).slice(2, 9);
const inputId = `file-input-${instanceSuffix}`;

const croppedImageData = ref<string>('');
const isLoading = ref(false);
const isProcessing = ref(false);
let processingVersion = 0;
const resetFileInputBeforeSelect = (event: Event) => {
  // Ensure selecting the same file triggers change every time.
  const target = event.target as HTMLInputElement;
  target.value = '';
};

// use label[for] to open file dialog; no programmatic click to avoid browser-specific hangs

const handleFileSelect = async (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (!file) return;

  // TEMP: 2MB limit disabled for debugging large image uploads.
  // const maxSizeBytes = 2 * 1024 * 1024;
  // if (file.size > maxSizeBytes) {
  //   alert('❌ File size exceeds 2MB limit');
  //   // Reset file input
  //   target.value = '';
  //   return;
  // }

  // Validate file format
  if (!['image/jpeg', 'image/png'].includes(file.type)) {
    alert('❌ Only JPG and PNG formats are supported');
    // Reset file input
    target.value = '';
    return;
  }

  isLoading.value = true;
  const runVersion = ++processingVersion;

  try {
    // Let the browser finish file-picker UI work before heavy processing.
    await new Promise((resolve) => window.setTimeout(resolve, 0));
    await cropImage(file, runVersion);
  } catch (error) {
    console.error('Error in handleFileSelect:', error);
    alert('Error selecting file. Please try again.');
    if (runVersion === processingVersion) {
      resetImage();
    }
  } finally {
    if (runVersion === processingVersion) {
      isLoading.value = false;
    }
  }
};

// No imperative initialization required for vue3-cropper; the component will mount with imagePreview

// no native image load handling needed for vue-advanced-cropper

const fileToDataUrl = (blob: Blob) => new Promise<string>((resolve, reject) => {
  const reader = new FileReader();
  reader.onloadend = () => {
    const result = reader.result;
    if (typeof result === 'string') {
      resolve(result);
      return;
    }
    reject(new Error('Failed to convert image to base64'));
  };
  reader.onerror = (e) => reject(e);
  reader.readAsDataURL(blob);
});

const cropImage = async (file: File, runVersion: number) => {
  // Crop to centered square automatically and normalize output to 800x800 PNG.
  if (runVersion !== processingVersion) return;
  isProcessing.value = true;
  try {
    let width = 0;
    let height = 0;
    let source: CanvasImageSource | null = null;
    let bitmap: ImageBitmap | null = null;

    try {
      if ('createImageBitmap' in window) {
        bitmap = await createImageBitmap(file);
        width = bitmap.width;
        height = bitmap.height;
        source = bitmap;
      } else {
        const fallbackImage = new Image();
        const objectUrl = URL.createObjectURL(file);
        fallbackImage.src = objectUrl;
        await new Promise((res, rej) => {
          fallbackImage.onload = res;
          fallbackImage.onerror = rej;
        });
        URL.revokeObjectURL(objectUrl);
        width = fallbackImage.naturalWidth;
        height = fallbackImage.naturalHeight;
        source = fallbackImage;
      }

      if (runVersion !== processingVersion || !source) return;

      const cropSize = Math.min(width, height, 800);
      const sx = Math.floor((width - cropSize) / 2);
      const sy = Math.floor((height - cropSize) / 2);
      const off = document.createElement('canvas');
      off.width = 800;
      off.height = 800;
      const ctx = off.getContext('2d');
      if (!ctx) throw new Error('Canvas context unavailable');
      ctx.fillStyle = '#fff';
      ctx.fillRect(0, 0, 800, 800);
      ctx.drawImage(source, sx, sy, cropSize, cropSize, 0, 0, 800, 800);

      const blob = await new Promise<Blob | null>((resolve) => {
        off.toBlob((b) => resolve(b), 'image/png');
      });

      if (!blob) {
        alert('Error creating image blob. Please try again.');
        return;
      }

      // Yield once before base64 conversion to keep UI responsive.
      await new Promise((resolve) => window.setTimeout(resolve, 0));
      if (runVersion !== processingVersion) return;

      const base64 = await fileToDataUrl(blob);

      if (runVersion !== processingVersion) return;
      croppedImageData.value = base64;
      emit('imageSelected', croppedImageData.value);
    } catch (e) {
      console.error('Auto crop failed', e);
      alert('Error cropping image. Please try again.');
    } finally {
      if (bitmap) {
        bitmap.close();
      }
    }
  } catch (error) {
    console.error('Error cropping image:', error);
    alert('Error cropping image. Please try again.');
  } finally {
    if (runVersion === processingVersion) {
      isProcessing.value = false;
    }
  }
};

const resetImage = () => {
  processingVersion += 1;
  croppedImageData.value = '';
  // Reset file input
  if (fileInputEl.value) {
    fileInputEl.value.value = '';
  }
};


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


</style>

