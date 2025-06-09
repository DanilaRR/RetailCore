<template>
  <div class="home-container">
    <nav>
      <!-- Show Home only if logged in -->
      <router-link v-if="isLoggedIn" to="/home">Home</router-link>

      <!-- Show Register and Login only if not logged in -->
      <router-link v-if="!isLoggedIn" to="/register">Register</router-link>
      <span v-if="!isLoggedIn"> | </span>
      <router-link v-if="!isLoggedIn" to="/login">Login</router-link>

    </nav>
    <router-view />
    <button v-if="isLoggedIn" @click="logout" class="logout-button">Logout </button>
  </div>
</template>

<script setup lang="ts">
import { ref, provide, onMounted } from 'vue';
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

// Logout function
const logout = () => {
  localStorage.removeItem('token');
  isLoggedIn.value = false; // Update the reactive state
  router.push('/login');
};
</script>
