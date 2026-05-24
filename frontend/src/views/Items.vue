<template>
  <div class="items-container">
    <h2>Our Items</h2>

    <div v-if="loading" class="loading">Loading items...</div>

    <div v-if="error" class="error">{{ error }}</div>

    <div v-if="!loading && items.length === 0 && !error" class="no-items">
      No items available
    </div>

    <div v-if="!loading && items.length > 0" class="items-grid">
      <div v-for="item in items" :key="item.id" class="item-card">
        <h3>{{ item.name }}</h3>
        <p><strong>Category:</strong> {{ item.category || 'Other' }}</p>
        <p><strong>Price:</strong> ${{ item.price }}</p>
        <router-link :to="`/items/${item.id}`" class="btn-view">View Details</router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import axios from 'axios';

interface Item {
  id: number;
  name: string;
  price: number;
  category?: string;
}

const items = ref<Item[]>([]);
const loading = ref(false);
const error = ref<string | null>(null);

const fetchItems = async () => {
  try {
    loading.value = true;
    error.value = null;
    const token = localStorage.getItem('token');

    const response = await axios.get('http://localhost:8081/api/items', {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    items.value = response.data;
  } catch (err: any) {
    if (err.response && err.response.status === 401) {
      error.value = 'Unauthorized. Please login again.';
      localStorage.removeItem('token');
      // Redirect to login after a delay
      setTimeout(() => {
        window.location.href = '/login';
      }, 2000);
    } else {
      error.value = 'Failed to load items. Please try again.';
    }
    console.error('Error fetching items:', err);
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchItems();
});
</script>

<style scoped>
.items-container {
  max-width: 1200px;
  margin: 20px auto;
  padding: 20px;
}

h2 {
  color: #333;
  margin-bottom: 20px;
}

.loading,
.error,
.no-items {
  text-align: center;
  padding: 20px;
  border-radius: 4px;
}

.loading {
  background-color: #e3f2fd;
  color: #1976d2;
}

.error {
  background-color: #ffebee;
  color: #c62828;
  font-weight: bold;
}

.no-items {
  background-color: #f5f5f5;
  color: #666;
}

.items-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
}

.item-card {
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 15px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
}

.item-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.item-card h3 {
  margin: 0 0 10px 0;
  color: #333;
}

.item-card p {
  margin: 8px 0;
  color: #666;
  font-size: 14px;
}

.btn-view {
  display: inline-block;
  margin-top: 10px;
  padding: 8px 16px;
  background-color: #007bff;
  color: white;
  text-decoration: none;
  border-radius: 4px;
  font-size: 14px;
}

.btn-view:hover {
  background-color: #0056b3;
}
</style>

