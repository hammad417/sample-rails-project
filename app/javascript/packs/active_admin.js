// Load Active Admin's styles into Webpacker,
// see `active_admin.scss` for customization.
import "../stylesheets/active_admin";

import "@activeadmin/activeadmin";

$(document).ready(function () {
    $(".signature_fields_wrapper input[type='radio']").click(function () {
        const showTargetId = $(this).attr('data-show-target-id');
        const hideTargetId = $(this).attr('data-hide-target-id');
        $(`#${showTargetId}`).show()
        $(`#${hideTargetId}`).hide()
    });

    $(".document_type").change(function () {
        const val = $(this).val()
        if (val === "OTHER") {
            $(".other_document_type").attr('disabled', false).val('').show()
        } else {
            $(".other_document_type").attr('disabled', true).val('').hide()
        }
    })

    $(".document_type").trigger('change')
})