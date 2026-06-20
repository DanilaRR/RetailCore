<template>
  <main class="categories-page">
    <header class="page-header">
      <div>
        <h1>Categories</h1>
        <p>Select a category to view its items</p>
      </div>
      <button type="button" class="create-button" @click="openCreateModal">
        ➕ Create Category
      </button>
    </header>

    <p v-if="error" class="message error">{{ error }}</p>
    <p v-if="success" class="message success">{{ success }}</p>

    <p v-if="loading" class="empty-state">Loading categories...</p>
    <p v-else-if="categories.length === 0" class="empty-state">
      No categories yet. Create one to get started!
    </p>
    <div v-else class="categories-grid">
      <router-link
        v-for="category in categories"
        :key="category.id"
        :to="`/category/${category.id}`"
        class="category-card"
      >
        <div class="category-icon">📁</div>
        <h2>{{ category.name }}</h2>
        <p class="item-count">Items</p>
        <button
          type="button"
          class="delete-button"
          @click.prevent="deleteCategory(category.id, category.name)"
        >
          🗑️ Delete
        </button>
      </router-link>
    </div>

    <!-- Modal for creating category -->
    <div v-if="showModal" class="modal-overlay" @click="closeCreateModal">
      <div class="modal" @click.stop>
        <div class="modal-header">
          <h2>Create New Category</h2>
          <button type="button" class="close-button" @click="closeCreateModal">✕</button>
        </div>
        <form @submit.prevent="createCategory">
          <label for="category-name">Category Name</label>
          <input
            id="category-name"
            v-model.trim="modalForm.name"
            type="text"
            placeholder="e.g., Books, Electronics, Clothing"
            :disabled="isSubmitting"
            required
            autofocus
          />
          <div class="modal-actions">
            <button type="button" class="cancel-button" @click="closeCreateModal">
              Cancel
            </button>
            <button
              type="submit"
              class="submit-button"
              :disabled="isSubmitting || !modalForm.name"
            >
              {{ isSubmitting ? 'Creating...' : 'Create' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </main>
</template>

<script setup lang="ts">
import { onMounted, ref, reactive } from 'vue';
import axios from 'axios';

interface Category {
  id: number;
  name: string;
}

const API_BASE_URL = 'http://localhost:8081';

const categories = ref<Category[]>([]);
const loading = ref(false);
const isSubmitting = ref(false);
const error = ref<string | null>(null);
const success = ref<string | null>(null);
const showModal = ref(false);

const modalForm = reactive({
  name: '',
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

const loadCategories = async () => {
  try {
    loading.value = true;
    error.value = null;

    const response = await axios.get<Category[]>(
      `${API_BASE_URL}/api/categories`,
      { headers: authHeaders() }
    );

    categories.value = response.data;
  } catch (err: any) {
    if (!handleUnauthorized(err)) {
      error.value = getErrorReason(err, 'Failed to load categories');
    }
  } finally {
    loading.value = false;
  }
};

const openCreateModal = () => {
  showModal.value = true;
  modalForm.name = '';
};

const closeCreateModal = () => {
  showModal.value = false;
  modalForm.name = '';
};

const createCategory = async () => {
  try {
    isSubmitting.value = true;
    error.value = null;
    success.value = null;

    const response = await axios.post<Category>(
      `${API_BASE_URL}/api/categories`,
      { name: modalForm.name },
      { headers: { ...authHeaders(), 'Content-Type': 'application/json' } }
    );

    success.value = `Category "${response.data.name}" created successfully!`;
    closeCreateModal();
    await loadCategories();
  } catch (err: any) {
    if (!handleUnauthorized(err)) {
      error.value = getErrorReason(err, 'Failed to create category');
    }
  } finally {
    isSubmitting.value = false;
  }
};

const deleteCategory = async (categoryId: number, categoryName: string) => {
  if (!confirm(`Are you sure you want to delete "${categoryName}"?`)) {
    return;
  }

  try {
    error.value = null;
    success.value = null;

    await axios.delete(
      `${API_BASE_URL}/api/categories/${categoryId}`,
      { headers: authHeaders() }
    );

    success.value = `Category "${categoryName}" deleted successfully!`;
    await loadCategories();
  } catch (err: any) {
    if (!handleUnauthorized(err)) {
      error.value = getErrorReason(err, 'Failed to delete category');
    }
  }
};


onMounted(() => {
  loadCategories();
});
</script>

<style scoped>
.categories-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 28px 20px 48px;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 28px;
}

h1,
h2,
p {
  margin: 0;
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

.create-button {
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

.create-button:hover {
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
  padding: 32px;
  text-align: center;
}

.categories-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 20px;
}

.category-card {
  display: grid;
  grid-template-rows: auto 1fr auto auto;
  gap: 12px;
  min-height: 200px;
  border: 2px solid #d7dee8;
  border-radius: 12px;
  padding: 20px;
  background: #ffffff;
  text-decoration: none;
  transition: all 0.2s ease;
  cursor: pointer;
}

.category-card:hover {
  border-color: #2563eb;
  box-shadow: 0 4px 12px rgba(37, 99, 235, 0.15);
  transform: translateY(-4px);
}

.category-icon {
  font-size: 40px;
  text-align: center;
}

.category-card h2 {
  color: #17202a;
  font-size: 20px;
  font-weight: 700;
  text-align: center;
  word-break: break-word;
}

.item-count {
  color: #5f6c7b;
  font-size: 14px;
  text-align: center;
}

.delete-button {
  align-self: end;
  min-height: 36px;
  border: 1px solid #dc2626;
  border-radius: 6px;
  padding: 0 12px;
  color: #dc2626;
  background: #fee2e2;
  cursor: pointer;
  font-weight: 600;
  font-size: 12px;
  transition: all 0.2s ease;
}

.delete-button:hover {
  background: #dc2626;
  color: #ffffff;
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

