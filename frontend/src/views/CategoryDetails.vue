<template>
  <main class="category-details-page">
    <header class="page-header">
      <div>
        <router-link to="/categories" class="back-link">← Back to Categories</router-link>
        <h1>{{ categoryName }}</h1>
        <p>{{ items.length }} items in this category</p>
      </div>
      <button type="button" class="add-item-button" @click="openItemModal">
        ➕ Add Item
      </button>
    </header>

    <p v-if="error" class="message error">{{ error }}</p>
    <p v-if="success" class="message success">{{ success }}</p>

    <p v-if="loading" class="empty-state">Loading items...</p>
    <p v-else-if="items.length === 0" class="empty-state">
      No items in this category yet. Add one to get started!
    </p>
    <div v-else class="items-grid">
      <article v-for="item in items" :key="item.id" class="item-card">
        <div class="item-image">
          <img
            v-if="item.image"
            :src="item.image"
            :alt="item.name"
            class="item-image-media"
            loading="lazy"
          />
          <span v-else class="item-image-placeholder">📦</span>
        </div>
        <div class="item-content">
          <h3>{{ item.name }}</h3>
          <p class="price">${{ formatPrice(item.price) }}</p>
        </div>
        <div class="item-actions">
          <button
            type="button"
            class="action-button edit-button"
            @click="editItem(item)"
            title="Edit"
          >
            ✏️
          </button>
          <button
            type="button"
            class="action-button delete-button"
            @click="deleteItem(item.id, item.name)"
            title="Delete"
          >
            🗑️
          </button>
        </div>
      </article>
    </div>

    <!-- Modal for creating/editing item -->
    <div v-if="showItemModal" class="modal-overlay" @click="closeItemModal">
      <div class="modal" @click.stop>
        <div class="modal-header">
          <h2>{{ editingItem ? 'Edit Item' : 'Create New Item' }}</h2>
          <button type="button" class="close-button" @click="closeItemModal">✕</button>
        </div>
        <form @submit.prevent="saveItem">
          <!-- Image uploader for creating and editing items -->
          <div class="form-section">
            <label>Item Image</label>
            <div v-if="editingItem && itemForm.existingImage" class="image-preview-section">
              <div class="current-image-preview" :style="{ backgroundImage: `url(${itemForm.existingImage})` }"></div>
              <p class="image-label">Current Image</p>
              <label class="image-action-label">
                <input
                  type="checkbox"
                  v-model="shouldReplaceImage"
                  :disabled="isSubmitting"
                />
                Replace with new image
              </label>
            </div>
            <!-- Show uploader when creating a new item, or when replacing existing image -->
            <ImageUploader
              v-if="!editingItem || shouldReplaceImage"
              ref="imageUploaderRef"
              @imageSelected="handleImageSelected"
            />
            <p v-if="editingItem && !shouldReplaceImage && itemForm.existingImage" class="info-text">✓ Existing image will be kept</p>
          </div>

          <label for="item-name">Item Name</label>
          <input
            id="item-name"
            v-model.trim="itemForm.name"
            type="text"
            placeholder="e.g., Product Name"
            :disabled="isSubmitting"
            required
            autofocus
          />

          <label for="item-price">Price</label>
          <input
            id="item-price"
            v-model="itemForm.price"
            type="number"
            min="0.01"
            step="0.01"
            placeholder="0.00"
            :disabled="isSubmitting"
            required
          />

          <div class="modal-actions">
            <button type="button" class="cancel-button" @click="closeItemModal">
              Cancel
            </button>
            <button
              type="submit"
              class="submit-button"
              :disabled="isSubmitting || !itemForm.name || !itemForm.price"
            >
              {{ isSubmitting ? (editingItem ? 'Updating...' : 'Creating...') : (editingItem ? 'Update' : 'Create') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </main>
</template>

<script setup lang="ts">
import { onMounted, ref, reactive, computed, watch } from 'vue';
import { useRoute } from 'vue-router';
import axios from 'axios';
import ImageUploader from '../components/ImageUploader.vue';

interface Category {
  id: number;
  name: string;
}

interface Item {
  id: number;
  name: string;
  price: number | string;
  category?: string;
  image?: string;
}

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8081';
const route = useRoute();

const categoryId = computed(() => Number(route.params.categoryId));
const categoryName = ref('');
const items = ref<Item[]>([]);
const loading = ref(false);
const isSubmitting = ref(false);
const error = ref<string | null>(null);
const success = ref<string | null>(null);
const showItemModal = ref(false);
const editingItem = ref<Item | null>(null);
const selectedImage = ref<string | null>(null);
const shouldReplaceImage = ref(false);
const imageUploaderRef = ref<InstanceType<typeof ImageUploader> | null>(null);

const itemForm = reactive({
  name: '',
  price: '',
  existingImage: null as string | null,
});

const authHeaders = () => {
  const token = localStorage.getItem('token');
  return {
    Authorization: `Bearer ${token}`,
  };
};

const getErrorReason = (err: any, fallback: string) => {
  if (err.response) {
    const data = err.response.data;
    const reason = typeof data === 'string'
      ? data
      : data?.message || data?.error || JSON.stringify(data);

    return reason ? `${fallback}: ${reason}` : `${fallback}: HTTP ${err.response.status}`;
  }

  if (err.request) {
    return `${fallback}: item service did not respond`;
  }

  return `${fallback}: ${err.message || 'Unknown error'}`;
};

const handleUnauthorized = (err: any) => {
  if (err.response?.status === 401 || err.response?.status === 403) {
    localStorage.removeItem('token');
    error.value = 'Session expired or unauthorized. Please log in again.';
    setTimeout(() => {
      window.location.href = '/login';
    }, 1200);
    return true;
  }

  return false;
};

const getCategoryName = async () => {
  try {
    const response = await axios.get<Category[]>(
      `${API_BASE_URL}/api/categories`,
      { headers: authHeaders() }
    );

    const category = response.data.find(c => c.id === categoryId.value);
    if (category) {
      categoryName.value = category.name;
    }
  } catch (err: any) {
    if (!handleUnauthorized(err)) {
      error.value = getErrorReason(err, 'Failed to load category');
    }
  }
};

const loadItems = async () => {
  try {
    loading.value = true;
    error.value = null;

    const response = await axios.get<Item[]>(
      `${API_BASE_URL}/api/items`,
      { headers: authHeaders() }
    );

    // Filter items by category name
    items.value = response.data.filter(item => item.category === categoryName.value);

    // Load images for each item
    for (const item of items.value) {
      try {
        const imgResponse = await axios.get(
          `${API_BASE_URL}/api/items/${item.id}/image`,
          { headers: authHeaders() }
        );
        if (imgResponse.data?.imageData) {
          console.log(`Loaded image for item ${item.id}`);
          item.image = imgResponse.data.imageData;
        }
      } catch (imgErr) {
        console.log(`No image for item ${item.id}:`, (imgErr as any).response?.status);
        // Item doesn't have an image, that's okay
      }
    }
  } catch (err: any) {
    if (!handleUnauthorized(err)) {
      error.value = getErrorReason(err, 'Failed to load items');
    }
  } finally {
    loading.value = false;
  }
};

const openItemModal = () => {
  editingItem.value = null;
  itemForm.name = '';
  itemForm.price = '';
  itemForm.existingImage = null;
  selectedImage.value = null;
  shouldReplaceImage.value = false;
  showItemModal.value = true;
};

const closeItemModal = () => {
  showItemModal.value = false;
  editingItem.value = null;
  itemForm.name = '';
  itemForm.price = '';
  itemForm.existingImage = null;
  selectedImage.value = null;
  shouldReplaceImage.value = false;
  imageUploaderRef.value?.reset();
};

const handleImageSelected = (imageData: string) => {
  selectedImage.value = imageData;
};

// When user unchecks "replace image", clear any selected image
watch(shouldReplaceImage, (val) => {
  if (!val) {
    selectedImage.value = null;
    imageUploaderRef.value?.reset();
  }
});

const editItem = (item: Item) => {
  editingItem.value = item;
  itemForm.name = item.name;
  itemForm.price = String(item.price);
  itemForm.existingImage = item.image || null;
  shouldReplaceImage.value = false;
  selectedImage.value = null;
  showItemModal.value = true;
};

const saveItem = async () => {
  try {
    isSubmitting.value = true;
    error.value = null;
    success.value = null;

     if (editingItem.value) {
       // Update item
       await axios.patch(
         `${API_BASE_URL}/api/items/${editingItem.value.id}`,
         {
           name: itemForm.name,
           price: itemForm.price,
         },
         { headers: authHeaders() }
       );

       // If new image was selected for editing, upload it
       if (shouldReplaceImage.value && selectedImage.value && editingItem.value) {
         try {
           await axios.post(
             `${API_BASE_URL}/api/items/${editingItem.value.id}/upload-image`,
             { imageData: selectedImage.value },
             { headers: authHeaders() }
           );
           console.log('Image updated successfully');
         } catch (imgErr) {
           console.error('Image upload failed:', imgErr);
           // Item was updated successfully, image upload is secondary
         }
       }

       success.value = `Item "${itemForm.name}" updated successfully!`;
    } else {
      // Create item
      const formData = new FormData();
      formData.append('name', itemForm.name);
      formData.append('category', categoryName.value);
      formData.append('price', itemForm.price);

      const response = await axios.post(`${API_BASE_URL}/api/items/upload`, formData, {
        headers: authHeaders(),
      });

      // If image was selected, upload it
      console.log('Response from item creation:', response.data);
      if (selectedImage.value && response.data?.id) {
        const itemId = response.data.id;
        console.log('Uploading image for item ID:', itemId);
        try {
          const imgResponse = await axios.post(
            `${API_BASE_URL}/api/items/${itemId}/upload-image`,
            { imageData: selectedImage.value },
            { headers: authHeaders() }
          );
          console.log('Image upload response:', imgResponse.data);
        } catch (imgErr) {
          console.error('Image upload failed:', imgErr);
          // Item was created successfully, image upload is secondary
        }
      } else {
        console.log('No image selected or no item ID in response');
      }

      success.value = `Item "${itemForm.name}" created successfully!`;
    }

    closeItemModal();
    await loadItems();
  } catch (err: any) {
    if (!handleUnauthorized(err)) {
      error.value = getErrorReason(err, editingItem.value ? 'Failed to update item' : 'Failed to create item');
    }
  } finally {
    isSubmitting.value = false;
  }
};

const deleteItem = async (itemId: number, itemName: string) => {
  if (!confirm(`Are you sure you want to delete "${itemName}"?`)) {
    return;
  }

  try {
    error.value = null;
    success.value = null;

    await axios.delete(
      `${API_BASE_URL}/api/items/${itemId}`,
      { headers: authHeaders() }
    );

    success.value = `Item "${itemName}" deleted successfully!`;
    await loadItems();
  } catch (err: any) {
    if (!handleUnauthorized(err)) {
      error.value = getErrorReason(err, 'Failed to delete item');
    }
  }
};

const formatPrice = (price: number | string) => {
  const value = Number(price);
  return Number.isFinite(value) ? value.toFixed(2) : price;
};

onMounted(async () => {
  await getCategoryName();
  await loadItems();
});
</script>

<style scoped>
.category-details-page {
  width: 100%;
  max-width: none;
  margin: 0;
  padding: 28px 24px 48px;
  box-sizing: border-box;
}

.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 28px;
}

h1,
h2,
p {
  margin: 0;
}

.back-link {
  display: inline-block;
  color: #2563eb;
  text-decoration: none;
  font-weight: 600;
  margin-bottom: 8px;
  font-size: 14px;
}

.back-link:hover {
  text-decoration: underline;
}

h1 {
  color: #17202a;
  font-size: 32px;
  margin-bottom: 6px;
}

.page-header p {
  color: #5f6c7b;
  font-size: 14px;
}

.add-item-button {
  min-height: 42px;
  border: 0;
  border-radius: 6px;
  padding: 0 16px;
  color: #ffffff;
  background: #2563eb;
  cursor: pointer;
  font-weight: 700;
  white-space: nowrap;
}

.add-item-button:hover {
  background: #1d4ed8;
}

.message {
  margin-bottom: 16px;
  border-radius: 6px;
  padding: 12px 14px;
  font-weight: 700;
}

.error {
  background: #fde8e8;
  color: #9b1c1c;
}

.success {
  background: #e6f6ec;
  color: #116149;
}

.empty-state {
  color: #5f6c7b;
  background: #f8fafc;
  border: 1px dashed #c9d3df;
  border-radius: 6px;
  padding: 48px;
  text-align: center;
}

.items-grid {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 16px;
}

.item-card {
  display: flex;
  flex-direction: column;
  border: 1px solid #d7dee8;
  border-radius: 12px;
  padding: 16px;
  background: #ffffff;
  position: relative;
  overflow: hidden;
  transition: all 0.2s ease;
  min-height: 260px;
}

.item-card:hover {
  border-color: #2563eb;
  box-shadow: 0 4px 12px rgba(37, 99, 235, 0.15);
  transform: translateY(-2px);
}

.item-image {
  width: 100%;
  aspect-ratio: 1 / 1;
  margin-bottom: 12px;
  border-radius: 8px;
  background-color: #f0f0f0;
  overflow: hidden;
}

.item-image-media {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.item-image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 48px;
}

.item-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 12px;
}

.item-card h3 {
  color: #17202a;
  font-size: 16px;
  font-weight: 700;
  margin: 0;
  word-break: break-word;
  line-height: 1.3;
}

.price {
  color: #116149;
  font-size: 18px;
  font-weight: 700;
  margin: 0;
}

.item-actions {
  display: flex;
  gap: 8px;
}

.action-button {
  flex: 1;
  min-height: 36px;
  border: 1px solid #d7dee8;
  border-radius: 6px;
  padding: 0 8px;
  background: #f8fafc;
  cursor: pointer;
  font-size: 18px;
  transition: all 0.2s ease;
}

.action-button:hover {
  background: #e5e7eb;
  border-color: #9ca3af;
}

.delete-button:hover {
  background: #fee2e2;
  border-color: #dc2626;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  background: #ffffff;
  border-radius: 12px;
  padding: 0;
  max-width: 400px;
  width: 90%;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h2 {
  color: #17202a;
  font-size: 20px;
}

.close-button {
  background: none;
  border: none;
  font-size: 24px;
  color: #5f6c7b;
  cursor: pointer;
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-button:hover {
  color: #17202a;
}

form {
  padding: 20px;
  display: grid;
  gap: 16px;
  max-height: 70vh;
  overflow-y: auto;
}

.form-section {
  display: grid;
  gap: 8px;
}

label {
  color: #324052;
  font-size: 13px;
  font-weight: 700;
}

input {
  min-height: 42px;
  width: 100%;
  border: 1px solid #c9d3df;
  border-radius: 6px;
  padding: 0 12px;
  box-sizing: border-box;
  color: #17202a;
  background: #ffffff;
  font-size: 14px;
}

input:focus {
  outline: none;
  border-color: #2563eb;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}

.image-preview-section {
  display: grid;
  gap: 12px;
  padding: 12px;
  background: #f0f4f8;
  border-radius: 6px;
  margin-bottom: 12px;
}

.current-image-preview {
  width: 100%;
  height: 150px;
  background-size: cover;
  background-position: center;
  border-radius: 4px;
  border: 1px solid #c9d3df;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  background-color: #e5e7eb;
}

.image-label {
  font-size: 12px;
  color: #666;
  margin: 0;
  font-weight: 600;
}

.image-action-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: normal;
  cursor: pointer;
  padding: 6px;
  user-select: none;
}

.image-action-label input[type="checkbox"] {
  width: auto;
  min-height: auto;
  border: 1px solid #c9d3df;
  padding: 0;
  cursor: pointer;
  margin: 0;
}

.info-text {
  font-size: 13px;
  color: #16a34a;
  margin: 0;
  padding: 8px 12px;
  background: #f0fdf4;
  border-radius: 4px;
  border-left: 3px solid #16a34a;
}
.modal-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-top: 8px;
}

.cancel-button,
.submit-button {
  min-height: 42px;
  border: 0;
  border-radius: 6px;
  padding: 0 16px;
  cursor: pointer;
  font-weight: 700;
  font-size: 14px;
}

.cancel-button {
  color: #17202a;
  background: #e5e7eb;
}

.cancel-button:hover {
  background: #d1d5db;
}

.submit-button {
  color: #ffffff;
  background: #2563eb;
}

.submit-button:hover:not(:disabled) {
  background: #1d4ed8;
}

.submit-button:disabled {
  background: #aab6c5;
  cursor: not-allowed;
}
</style>

