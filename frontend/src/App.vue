<template>
  <div class="home-container">
    <nav class="navbar">
      <!-- Show Home only if logged in -->
      <router-link v-if="isLoggedIn" to="/home" class="nav-link">Home</router-link>

      <!-- Show Register and Login only if not logged in -->
      <router-link v-if="!isLoggedIn" to="/register" class="nav-link">Register</router-link>
      <span v-if="!isLoggedIn" class="separator"> | </span>
      <router-link v-if="!isLoggedIn" to="/login" class="nav-link">Login</router-link>
    </nav>
    <router-view />
    <button v-if="isLoggedIn" @click="logout" class="logout-button">Logout</button>
  </div>
</template>

<script setup lang="ts">
import { ref, provide, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const isLoggedIn = ref(false);

// Provide the reactive variable to other components
provide('isLoggedIn', isLoggedIn);

// Function to check authentication status
const checkAuth = () => {
  isLoggedIn.value = !!localStorage.getItem('token');
};

// Check authentication status when the component is mounted
onMounted(() => {
  checkAuth();
});

// Watch for route changes to update auth status
watch(() => router.currentRoute.value.path, () => {
  checkAuth();
});

// Logout function
const logout = () => {
  localStorage.removeItem('token');
  isLoggedIn.value = false; // Update the reactive state
  router.push('/login');
};
</script>

<style scoped>
.home-container {
  min-height: 100vh;
  background-color: #f5f5f5;
}

.navbar {
  background-color: #333;
  padding: 15px 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  gap: 15px;
  align-items: center;
}

.nav-link {
  color: white;
  text-decoration: none;
  padding: 8px 12px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.nav-link:hover {
  background-color: #555;
}

.separator {
  color: white;
}

.logout-button {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 10px 20px;
  background-color: #dc3545;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
  z-index: 100;
}

.logout-button:hover {
  background-color: #c82333;
}
</style>
