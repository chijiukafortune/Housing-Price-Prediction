document.addEventListener("DOMContentLoaded", function () {
  const sidebar = document.querySelector(".sidebar");
  const toggleBtn = document.querySelector(".toggle-btn");

  // Toggle sidebar collapse/expand
  toggleBtn.addEventListener("click", function () {
    sidebar.classList.toggle("collapsed");
  });
});

$(document).ready(function(){
  $('#LND_SQFOOT').on('input', function() {
    this.value = this.value.replace(/[^0-9\.]/g, '');
  });
  $('#TOT_LVG_AREA').on('input', function() {
    this.value = this.value.replace(/[^0-9\.]/g, '');
  });
  $('#SPEC_FEAT_VAL').on('input', function() {
    this.value = this.value.replace(/[^0-9\.]/g, '');
  });
  $('#RAIL_DIST').on('input', function() {
    this.value = this.value.replace(/[^0-9\.]/g, '');
  });
  $('#OCEAN_DIST').on('input', function() {
    this.value = this.value.replace(/[^0-9\.]/g, '');
  });
  $('#WATER_DIST').on('input', function() {
    this.value = this.value.replace(/[^0-9\.]/g, '');
  });
  $('#CNTR_DIST').on('input', function() {
    this.value = this.value.replace(/[^0-9\.]/g, '');
  });
  $('#SUBCNTR_DI').on('input', function() {
    this.value = this.value.replace(/[^0-9\.]/g, '');
  });
  $('#HWY_DIST').on('input', function() {
    this.value = this.value.replace(/[^0-9\.]/g, '');
  });
  $('#age').on('input', function() {
    this.value = this.value.replace(/[^0-9\.]/g, '');
  });
  $('#structure_quality').on('input', function() {
    this.value = this.value.replace(/[^0-9\.]/g, '');
  });
});



// Listen for the custom event to apply the exact match filter on SALE_PRC column (index 11)
Shiny.addCustomMessageHandler("applyExactMatchFilter", function(message) {
  $('#houses_table').DataTable().on('draw', function() {
    var searchBox = $('input[type="search"]');
    
    searchBox.on('input', function() {
      var query = searchBox.val();
      var table = $('#houses_table').DataTable();
      
      // Remove commas from the SALE_PRC column and match exactly
      table.column(11).search(function(settings, data, rowIndex) {
        var cellValue = data[11].replace(/,/g, '');  // Remove commas from the value
        return cellValue === query;  // Exact match only
      }, true, false).draw();
    });
  });
});


/// Handling login

document.getElementById("login-button").addEventListener("click", function() {
  // Show the loader by disabling the button
  document.getElementById("login-button").disabled = true;

  // Show the invalid password alert (you can customize this condition based on your app logic)
  let passwordInput = document.getElementById("password");
  if (passwordInput.value !== "correct-password") {
    document.querySelector(".invalid-alert").classList.add("show");
  }
  
  // Simulate login processing (e.g., an AJAX request)
  setTimeout(function() {
    // Hide the loader and re-enable the button after processing
    document.getElementById("login-button").disabled = false;
    document.querySelector(".invalid-alert").classList.remove("show");
  }, 2000); // Simulate a delay of 2 seconds
});
