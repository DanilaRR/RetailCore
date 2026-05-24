<template>
  <div class="home-container">
    <h1>Welcome to Webstore!</h1>
    <p>This is your home page. Browse our items:</p>
    <router-link to="/items" class="btn-items">Go to Items</router-link>
  </div>
</template>

<script setup lang="ts">
// Home page component
</script>

<style scoped>
.home-container {
  max-width: 600px;
  margin: 50px auto;
  padding: 20px;
  text-align: center;
}

h1 {
  color: #333;
  margin-bottom: 20px;
}

p {
  color: #666;
  margin-bottom: 30px;
  font-size: 16px;
}

.btn-items {
  display: inline-block;
  padding: 10px 30px;
  background-color: #007bff;
  color: white;
  text-decoration: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
}

.btn-items:hover {
  background-color: #0056b3;
}
</style>

