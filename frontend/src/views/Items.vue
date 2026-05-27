<template>
  <main class="items-page">
    <header class="page-header">
      <div>
        <h1>Catalog</h1>
        <p>Create a category first, then add items to it.</p>
      </div>
      <button type="button" class="refresh-button" :disabled="loading" @click="loadCatalog">
        {{ loading ? 'Refreshing...' : 'Refresh' }}
      </button>
    </header>

    <p v-if="error" class="message error">{{ error }}</p>
    <p v-if="success" class="message success">{{ success }}</p>

    <section class="workspace">
      <form class="panel" @submit.prevent="createCategory">
        <h2>Create Category</h2>
        <label for="category-name">Category name</label>
        <div class="inline-form">
          <input
            id="category-name"
            v-model.trim="categoryForm.name"
            type="text"
            placeholder="Books"
            :disabled="categorySubmitting"
            required
          />
          <button type="submit" :disabled="categorySubmitting || !categoryForm.name">
            {{ categorySubmitting ? 'Creating...' : 'Create' }}
          </button>
        </div>
      </form>

      <form class="panel" @submit.prevent="createItem">
        <h2>Create Item</h2>
        <label for="item-name">Item name</label>
        <input
          id="item-name"
          v-model.trim="itemForm.name"
          type="text"
          placeholder="Clean Code"
          :disabled="itemSubmitting"
          required
        />

        <label for="item-category">Category</label>
        <select
          id="item-category"
          v-model="itemForm.category"
          :disabled="itemSubmitting || categories.length === 0"
          required
        >
          <option value="" disabled>Select category</option>
          <option v-for="category in categories" :key="category.id" :value="category.name">
            {{ category.name }}
          </option>
        </select>

        <label for="item-price">Price</label>
        <input
          id="item-price"
          v-model="itemForm.price"
          type="number"
          min="0.01"
          step="0.01"
          placeholder="39.99"
          :disabled="itemSubmitting"
          required
        />

        <button
          type="submit"
          :disabled="itemSubmitting || categories.length === 0 || !itemForm.name || !itemForm.category || !itemForm.price"
        >
          {{ itemSubmitting ? 'Creating...' : 'Create Item' }}
        </button>
      </form>
    </section>

    <section class="content-grid">
      <div class="list-section">
        <div class="section-heading">
          <h2>Categories</h2>
          <span>{{ categories.length }}</span>
        </div>
        <p v-if="!loading && categories.length === 0" class="empty-state">
          No categories yet.
        </p>
        <ul v-else class="category-list">
          <li v-for="category in categories" :key="category.id">
            {{ category.name }}
          </li>
        </ul>
      </div>

      <div class="list-section">
        <div class="section-heading">
          <h2>Items</h2>
          <span>{{ items.length }}</span>
        </div>
        <p v-if="loading" class="empty-state">Loading catalog...</p>
        <p v-else-if="items.length === 0" class="empty-state">
          No items yet.
        </p>
        <div v-else class="items-grid">
          <article v-for="item in items" :key="item.id" class="item-card">
            <h3>{{ item.name }}</h3>
            <p>{{ item.category || 'Other' }}</p>
            <strong>${{ formatPrice(item.price) }}</strong>
          </article>
        </div>
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue';
import axios from 'axios';

interface Category {
  id: number;
  name: string;
}

interface Item {
  id: number;
  name: string;
  price: number | string;
  category?: string;
}

const API_BASE_URL = 'http://localhost:8081';

const categories = ref<Category[]>([]);
const items = ref<Item[]>([]);
const loading = ref(false);
const categorySubmitting = ref(false);
const itemSubmitting = ref(false);
const error = ref<string | null>(null);
const success = ref<string | null>(null);

const categoryForm = reactive({
  name: '',
});

const itemForm = reactive({
  name: '',
  category: '',
  price: '',
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

const loadCatalog = async () => {
  try {
    loading.value = true;
    error.value = null;

    const [categoriesResponse, itemsResponse] = await Promise.all([
      axios.get<Category[]>(`${API_BASE_URL}/api/categories`, { headers: authHeaders() }),
      axios.get<Item[]>(`${API_BASE_URL}/api/items`, { headers: authHeaders() }),
    ]);

    categories.value = categoriesResponse.data;
    items.value = itemsResponse.data;

    if (!itemForm.category && categories.value.length > 0) {
      itemForm.category = categories.value[0].name;
    }
  } catch (err: any) {
    if (!handleUnauthorized(err)) {
      error.value = getErrorReason(err, 'Failed to load catalog');
    }
  } finally {
    loading.value = false;
  }
};

const createCategory = async () => {
  try {
    categorySubmitting.value = true;
    error.value = null;
    success.value = null;

    const response = await axios.post<Category>(
      `${API_BASE_URL}/api/categories`,
      { name: categoryForm.name },
      { headers: { ...authHeaders(), 'Content-Type': 'application/json' } }
    );

    categoryForm.name = '';
    itemForm.category = response.data.name;
    success.value = `Category "${response.data.name}" created.`;
    await loadCatalog();
  } catch (err: any) {
    if (!handleUnauthorized(err)) {
      error.value = getErrorReason(err, 'Failed to create category');
    }
  } finally {
    categorySubmitting.value = false;
  }
};

const createItem = async () => {
  try {
    itemSubmitting.value = true;
    error.value = null;
    success.value = null;

    const formData = new FormData();
    formData.append('name', itemForm.name);
    formData.append('category', itemForm.category);
    formData.append('price', itemForm.price);

    await axios.post(`${API_BASE_URL}/api/items/upload`, formData, {
      headers: authHeaders(),
    });

    const createdName = itemForm.name;
    itemForm.name = '';
    itemForm.price = '';
    success.value = `Item "${createdName}" created.`;
    await loadCatalog();
  } catch (err: any) {
    if (!handleUnauthorized(err)) {
      error.value = getErrorReason(err, 'Failed to create item');
    }
  } finally {
    itemSubmitting.value = false;
  }
};

const formatPrice = (price: number | string) => {
  const value = Number(price);
  return Number.isFinite(value) ? value.toFixed(2) : price;
};

onMounted(() => {
  loadCatalog();
});
</script>

<style scoped>
.items-page {
  max-width: 1180px;
  margin: 0 auto;
  padding: 28px 20px 48px;
}

.page-header,
.section-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

.page-header {
  margin-bottom: 22px;
}

h1,
h2,
h3,
p {
  margin: 0;
}

h1 {
  color: #17202a;
  font-size: 32px;
}

h2 {
  color: #17202a;
  font-size: 18px;
}

.page-header p {
  margin-top: 6px;
  color: #5f6c7b;
}

.workspace {
  display: grid;
  grid-template-columns: minmax(280px, 1fr) minmax(320px, 1.4fr);
  gap: 18px;
  margin-bottom: 24px;
}

.panel,
.list-section {
  background: #ffffff;
  border: 1px solid #d7dee8;
  border-radius: 8px;
  padding: 18px;
  box-shadow: 0 1px 4px rgba(17, 24, 39, 0.06);
}

.panel {
  display: grid;
  gap: 10px;
  align-content: start;
}

.inline-form {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 10px;
}

label {
  color: #324052;
  font-size: 13px;
  font-weight: 700;
}

input,
select {
  min-height: 42px;
  width: 100%;
  border: 1px solid #c9d3df;
  border-radius: 6px;
  padding: 0 12px;
  box-sizing: border-box;
  color: #17202a;
  background: #ffffff;
}

button {
  min-height: 42px;
  border: 0;
  border-radius: 6px;
  padding: 0 16px;
  color: #ffffff;
  background: #2563eb;
  cursor: pointer;
  font-weight: 700;
}

button:disabled {
  background: #aab6c5;
  cursor: not-allowed;
}

.refresh-button {
  background: #2f4858;
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

.content-grid {
  display: grid;
  grid-template-columns: 280px minmax(0, 1fr);
  gap: 18px;
}

.section-heading {
  margin-bottom: 14px;
}

.section-heading span {
  min-width: 32px;
  border-radius: 999px;
  padding: 4px 10px;
  text-align: center;
  color: #ffffff;
  background: #2f4858;
  font-size: 13px;
  font-weight: 700;
}

.category-list {
  display: grid;
  gap: 8px;
  margin: 0;
  padding: 0;
  list-style: none;
}

.category-list li {
  border: 1px solid #d7dee8;
  border-radius: 6px;
  padding: 10px 12px;
  color: #253142;
  background: #f8fafc;
}

.items-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
  gap: 14px;
}

.item-card {
  display: grid;
  gap: 8px;
  min-height: 120px;
  border: 1px solid #d7dee8;
  border-radius: 8px;
  padding: 16px;
  background: #ffffff;
}

.item-card h3 {
  color: #17202a;
  font-size: 18px;
}

.item-card p {
  color: #5f6c7b;
}

.item-card strong {
  color: #116149;
  font-size: 20px;
}

.empty-state {
  color: #5f6c7b;
  background: #f8fafc;
  border: 1px dashed #c9d3df;
  border-radius: 6px;
  padding: 16px;
}

@media (max-width: 760px) {
  .page-header,
  .workspace,
  .content-grid {
    grid-template-columns: 1fr;
  }

  .page-header {
    align-items: stretch;
  }

  .inline-form {
    grid-template-columns: 1fr;
  }
}
</style>
